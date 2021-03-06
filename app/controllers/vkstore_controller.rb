require 'json'
require 'net/http'
class VkstoreController < Spree::BaseController
  before_filter :vk_auth
  before_filter :vk_sess
  helper :taxons
  layout 'vkstore'
  def catalogue
    @products = Product.all
  end
  
  def show
    @product = Product.find(params[:id])
    @variants = Variant.active.find_all_by_product_id(@product.id,
                :include => [:option_values, :images])
    @product_properties = ProductProperty.find_all_by_product_id(@product.id,
                          :include => [:property])
    @selected_variant = @variants.detect { |v| v.available? }
  end

  def cart
    @order = current_order(true)
  end

  def pay
    user_id = current_user.login.split("@")[0]
    order = Order.find_by_id(params[:order_id])
    votes = (order.total.to_vk.to_f * 100).to_i
    rnd = rand(999)
    secret = SVP::CONFIG["vkontakte"]["secret"]
    api_id = SVP::CONFIG["vkontakte"]["app_id"].to_i
    test_mode = SVP::CONFIG["vkontakte"]["test_mode"].to_i
    sig = Digest::MD5.hexdigest("api_id=#{api_id}" + "format=json" + "method=secure.withdrawVotes" + "random=#{rnd}" + "test_mode=#{test_mode}" + "timestamp=#{Time.now.to_i}" + "uid=#{user_id}" + "votes=#{votes}" + secret)
    req = "http://api.vkontakte.ru/api.php?api_id=#{api_id}&method=secure.withdrawVotes&format=json&timestamp=#{Time.now.to_i}&random=#{rnd}&uid=#{user_id}&votes=#{votes}&test_mode=#{test_mode}&sig=#{sig}"
    result = JSON.parse(Net::HTTP.get(URI.parse(req)))
    if result["response"]
      payment = order.payments.build(:payment_method => order.payment_method)
      payment.state = "completed"
      payment.amount = order.total.to_f
      payment.save
      order.save!
      order.next! until order.state == "complete"
      session[:order_id] = nil
      flash[:notice] = I18n.t("payment_success")
      redirect_to vkcatalogue_path
    else
      flash[:error] = I18n.t("payment_fail")
      redirect_to vkcatalogue_path
    end
  end

  private

  def vk_auth
    #params[:user_id] = "382066" #debug
    unless params[:user_id].nil?
      email = params[:user_id] + "@vkontakte.ru"
      u = User.find_by_email(email)
      if u.nil?
        u = User.new(:email => email, :login => email, :password => rand(99999999999))
        u.save
      end
      if current_user.nil?
        sign_in(u, :event => :authentication)
      end
    end
  end

  def vk_sess
    session[:from_social] = 'vk'
  end
end
