require 'json'
require 'net/http'
class FbstoreController < Spree::BaseController
  helper :taxons
  layout 'fbstore'
  def catalogue
    p params
    session = FacebookApi::Session.new(cookies["#{FacebookApi.api_key}_session_key"], cookies["#{FacebookApi.api_key}_user"])
    p session
    response = session.call('Friends.get', :uid => '100000412676930')
    p response

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
end
