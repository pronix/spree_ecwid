class Spree::BaseController < ActionController::Base
  before_filter :vk_auth

  private
  def vk_auth
  	params[:user_id] = "382066" #debug
  	unless params[:user_id].nil?
  	  email = params[:user_id] + "@vkontakte.ru"
  	  u = User.find_by_email(email)
  	  if u.nil?
  	    u = User.new(:email => email, :login => email, :password => rand(99999999999))
  	    if u.save
  	      p "+++++++++++"
  	    else
  	      p "-----------"
  	  	end
  	  end
  	  if current_user.nil?
  	  	sign_in(u, :event => :authentication)
  	  end
  	  p current_user.email
  	end
  end
end
