class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  #current_userが取れなかったらnil。micorposts_controllerでも使うのでusers_controllerから昇格。
  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      store_location
      redirect_to login_url
    end
  end
end
