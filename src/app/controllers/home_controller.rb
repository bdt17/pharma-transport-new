# app/controllers/home_controller.rb - ENHANCED VERSION
class HomeController < ApplicationController
  before_action :require_user!

  def index
    # Public landing page for marketing
    # Renders app/views/home/index.html.erb
  end

  private

  def require_user!
    unless user_signed_in?
      redirect_to new_user_session_path, 
        alert: "Please sign in to access Pharma Transport SaaS.", 
        status: :unauthorized
      return
    end
  end
end
