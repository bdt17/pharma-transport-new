class SessionsController < ApplicationController
  def new
  end
  
  def create
    if params[:email] == "admin@pharmatransport.com" && params[:password] == "pharma123"
      # ✅ PHASE 1: Password OK → PHASE 2: MFA
      session[:mfa_pending] = true
      session[:user_email] = params[:email]
      redirect_to mfa_path, notice: "🔐 Enter MFA code"
    else
      flash.now[:alert] = "❌ Invalid email/password"
      render :new, status: :unprocessable_entity
    end
  end
  
  def mfa
    unless session[:mfa_pending]
      redirect_to login_path, alert: "🔐 Login first"
    end
  end
  
  def verify_mfa
    if session[:mfa_pending] && params[:code] == "123456"
      session[:logged_in] = true
      session.delete(:mfa_pending)
      redirect_to root_path, notice: "✅ MFA verified - Welcome!"
    else
      flash.now[:alert] = "❌ Invalid MFA code"
      render :mfa, status: :unprocessable_entity
    end
  end
  
  def destroy
    reset_session
    redirect_to login_path, notice: "👋 Logged out"
  end
end
