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
    p params[:order_info]
    order = Order.find_by_id(params[:order_info])
    p order
    req = ""
    if params[:method] == "payments_get_items"
      req = '{"content":[{"title":"[Test Mode] Unicorn","description":"[Test Mode] Own your own mythical beast!","price":' + order.total.to_fb.to_i.to_s + ',"image_url":"http:\/\/www.facebook.com\/images\/gifts\/21.png","product_url":"http:\/\/www.facebook.com\/images\/gifts\/21.png"}],"method":"payments_get_items"}'
    elsif params[:method] == "payments_status_update"
      if params[:status] == 'placed'
        #req = '{"method":"payments_status_update","order_details":{"status":"settled","order_id":"' + params[:order_id] + '"}}'
        req = {:content=>{:status=>"settled", :order_id=>params[:order_id]}, :method=>"payments_status_update"}.to_json
        #req = '{"method":"payments_status_update","order_details":{"order_id":"' + params[:order_id] + '","status":"settled"}}'
      elsif params[:status] == 'settled'
        p "true"
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
