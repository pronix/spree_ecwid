class OrdersController < Spree::BaseController

  def populate
    @order = current_order(true)
    params[:products].each do |product_id,variant_id|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Hash)
      quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Hash)
      @order.add_variant(Variant.find(variant_id), quantity) if quantity > 0
    end if params[:products]

    params[:variants].each do |variant_id, quantity|
      quantity = quantity.to_i
      @order.add_variant(Variant.find(variant_id), quantity) if quantity > 0
    end if params[:variants]
    #To check if user submits order from 
    #Facebook or from fullfunctional shop
    if params[:from_fb] 
      redirect_to fbcart_path
    else
      redirect_to cart_path
    end
  end
end
