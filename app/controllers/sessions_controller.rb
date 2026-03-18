class SessionsController < ApplicationController
  def new
  end
  
  def create
    if params[:email] == "admin@pharmatransport.com" && params[:password] == "pharma123"
      session[:logged_in] = true
      session[:user_email] = params[:email]
      redirect_to root_path, notice: "✅ Logged in successfully!"
    else
      flash.now[:alert] = "❌ Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    session[:logged_in] = nil
    session[:user_email] = nil
    redirect_to login_path, notice: "👋 Logged out successfully!"
  end
end
