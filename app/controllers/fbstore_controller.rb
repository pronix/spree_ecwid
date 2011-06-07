require 'json'
require 'net/http'
class FbstoreController < Spree::BaseController
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

  def api
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
end
