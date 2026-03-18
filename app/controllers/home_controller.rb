class HomeController < ApplicationController
  def index
    if session[:logged_in]
      render layout: false
    else
      redirect_to login_path
    end
  end
  
  def pdf_health
    render plain: "PDF Service OK", status: :ok
  end
end
