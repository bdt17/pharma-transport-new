class SessionsController < ApplicationController
  def new; end
  
  def create
    if params[:email] == "admin@pharmatransport.com" && params[:password] == "AdminPharma2026!"
      session[:logged_in] = true
      session[:user_email] = params[:email]
      redirect_to root_path, notice: "✅ Login OK"
    else
      flash.now[:alert] = "❌ Invalid credentials"
      render :new
    end
  end
  
  def mfa
    session[:mfa_pending] = true if params[:mfa] == "true"
    render layout: false
  end
  
  def verify_mfa
    if params[:code] == "123456"
      session[:logged_in] = true
      redirect_to root_path
    else
      render :mfa
    end
  end
  
  def destroy
    reset_session
    redirect_to login_path
  end
end
