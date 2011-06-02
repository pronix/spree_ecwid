class CheckoutController < Spree::BaseController
  layout 'vkstore'
  def edit
  	p "!!!!!!!!!!!!!"
  	@order.rate_hash.each do |shipping_method|
  	  shipping_method[:cost] = shipping_method[:cost].to_vk
  	end
  	@item_total = @order.item_total.to_vk
  	@order_total = @order.total.to_vk
  end
end