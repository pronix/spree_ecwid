require 'json'
require 'net/http'
class FbstoreController < Spree::BaseController
  before_filter :fb_sess
  helper :taxons
  layout 'fbstore'
  def catalogue
    p params
    p cookies
    @oauth = Koala::Facebook::OAuth.new(126581324089558, "22a8623a09f4a9613dcb130552be822d")
    u = @oauth.get_user_info_from_cookies(cookies)
    p u
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

  def auth
    unless params[:user_id].nil?
      email = params[:user_id].to_i.to_s + "@facebook.com"
      p email
      u = User.find_by_email(email)
      p u
      if u.nil?
        u = User.new(:email => email, :login => email, :password => rand(99999999999))
        u.save
      end
      p u
      if current_user.nil?
        sign_in(u, :event => :authentication)
      end
      p current_user
    end
    render :nothing => true
  end

  def api
    p params
    req = ""
    if params[:method] == "payments_get_items"
      order = Order.find_by_id(params[:order_info])
      req = '{"content":[{"title":"[Test Mode] Unicorn","description":"[Test Mode] Own your own mythical beast!","price":' + order.total.to_fb.to_i.to_s + ',"image_url":"http:\/\/www.facebook.com\/images\/gifts\/21.png","product_url":"http:\/\/www.facebook.com\/images\/gifts\/21.png"}],"method":"payments_get_items"}'
    elsif params[:method] == "payments_status_update"
      if params[:status] == 'placed'
        req = {:content=>{:status=>"settled", :order_id=>params[:order_id]}, :method=>"payments_status_update"}.to_json
      elsif params[:status] == 'settled'
        order = Order.find_by_id(params[:order_id])
        p params[:order_id]
        p order
        payment = order.payments.build(:payment_method => order.payment_method)
        payment.state = "completed"
        payment.amount = order.total.to_f
        payment.save
        order.save!
        order.next! until order.state == "complete"
        session[:order_id] = nil
        flash[:notice] = I18n.t("payment_success")
        redirect_to fbcatalogue_path
      elsif params[:status] == 'settled'
        flash[:error] = I18n.t("payment_fail")
        redirect_to fbcatalogue_path
      end
    end
    p req
    render :text => req
  end

  private

  def fb_sess
    session[:from_social] = 'fb'
  end
end
