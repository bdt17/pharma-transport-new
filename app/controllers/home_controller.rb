class HomeController < ApplicationController
  def index
    if session[:logged_in]
      # Show dashboard
    else
      redirect_to login_path, alert: "🔐 Please log in"
    end
  end

  def pdf_health
    render plain: "PDF Service: OK - 21 CFR Part 11 Ready", status: :ok
  end
end
