class Spree::BaseController < ActionController::Base
  before_filter :vk_auth

  private
  def vk_auth
  	p params[:user_id]
  	unless params[:user_id].nil?
  	  email = params[:user_id] + "@vkontakte.ru"
  	  u = User.find_by_email(email)
  	  if u.nil?
  	    u = User.new(:email => email, :login => email, :password => rand(99999999999))
  	    u.save
  	  end
  	  unless current_user.nil?
  	  	sign_in(u, :event => :authentication) unless current_user
  	  end
  	  p current_user
  	end
  end
end
