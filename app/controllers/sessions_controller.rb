class SessionsController < ApplicationController
  def new
  end
  
  def create
    if params[:email] == "admin@pharmatransport.com" && params[:password] == "pharma123"
      session[:logged_in] = true
      session[:user_email] = params[:email]
      redirect_to root_path, notice: "✅ Welcome back!"
    else
      flash.now[:alert] = "❌ Invalid credentials"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    reset_session
    redirect_to login_path, notice: "👋 Logged out"
  end
end
