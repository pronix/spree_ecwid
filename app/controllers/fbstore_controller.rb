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
    req = ""
    if params[:method] == "payments_get_items"
      order = Order.find_by_id(params[:order_info])
      req = {:content => [{:title => "Title", :description => "Description", :price => order.total.to_fb.to_i.to_s, :item_id => order.id}], :method => "payments_get_items"}.to_json
      render :text => req
    elsif params[:method] == "payments_status_update"
      if params[:status] == 'placed'
        req = {:content=>{:status=>"settled", :order_id=>params[:order_id]}, :method=>"payments_status_update"}.to_json
        render :text => req
      elsif params[:status] == 'settled'
        order_details = JSON.parse(params[:order_details])
        item_id = order_details["items"][0]["item_id"]
        order = Order.find_by_id(item_id)
        payment = order.payments.build(:payment_method => order.payment_method)
        payment.state = "completed"
        payment.amount = order.total.to_f
        payment.save
        order.save!
        order.next! until order.state == "complete"
        session[:order_id] = nil
        flash[:notice] = I18n.t("payment_success")
        redirect_to fbcatalogue_path
      elsif params[:status] == 'refunded'
        flash[:error] = I18n.t("payment_fail")
        redirect_to fbcatalogue_path
      end
    end
  end

  private

  def fb_sess
    session[:from_social] = 'fb'
  end
end
