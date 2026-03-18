class HomeController < ApplicationController
  before_action :require_login, except: [:pdf_health]
  
  def index
    # Dashboard
  end
  
  def pdf_health
    render plain: "PDF Service: OK - 21 CFR Part 11 Ready", status: :ok
  end
  
  private
  
  def require_login
    unless session[:logged_in]
      redirect_to login_path, alert: "🔐 Please log in"
    end
  end
end
