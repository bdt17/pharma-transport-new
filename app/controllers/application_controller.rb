class ApplicationController < ActionController::Base
  helper_method :current_user
  def current_user
    nil  # Revenue-first - no auth
  end
  
  def user_signed_in?
    false
  end
end
