class CheckoutController < Spree::BaseController
  layout 'vkstore'
  def edit
  	@methods = []
  	if session[:from_social] == 'vk'
	  @order.rate_hash.each do |shipping_method|
	    shipping_method[:cost] = shipping_method[:cost].to_vk
	  end
	  @item_total = @order.item_total.to_vk
  	  @order_total = @order.total.to_vk
  	  @methods << PaymentMethod.find_by_type("Gateway::Vkontakte")
	elsif session[:from_social] == 'fb'
	  @order.rate_hash.each do |shipping_method|
	    shipping_method[:cost] = shipping_method[:cost].to_fb
	  end
	  @item_total = @order.item_total.to_fb
  	  @order_total = @order.total.to_fb
  	  @methods << PaymentMethod.find_by_type("Gateway::Facebook")
	else
	  @item_total = @order.item_total
  	  @order_total = @order.total
  	  @methods = @order.available_payment_methods
	end
	p session
	p @methods
  end
end