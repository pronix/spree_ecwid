class CheckoutController < Spree::BaseController
  def edit
  	p session
  	@methods = []
  	if session[:from_social] == 'vk'
  	  render :layout => 'vkstore'
	  @order.rate_hash.each do |shipping_method|
	    shipping_method[:cost] = shipping_method[:cost].to_vk
	  end
	  @item_total = @order.item_total.to_vk
  	  @order_total = @order.total.to_vk
  	  @methods << PaymentMethod.find_by_type("Gateway::Vkontakte")
	elsif session[:from_social] == 'fb'
	  render :layout => 'fbstore'
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
  end
end