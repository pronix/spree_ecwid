require 'json'
require 'net/http'
class FbstoreController < Spree::BaseController
  helper :taxons
  layout 'fbstore'
  def catalogue
    p params
    a = Koala::Facebook::OAuth.new(126581324089558, "d9426496ce5869ff9151d946cd20731b", "http://unfollowers.ru/fbstore/api/")
    p a
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
