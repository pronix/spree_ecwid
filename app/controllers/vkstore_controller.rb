class VkstoreController < Spree::BaseController
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
end
