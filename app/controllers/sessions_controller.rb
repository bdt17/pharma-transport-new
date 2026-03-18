class SessionsController < ApplicationController
  def new; end
  
  def create
    if params[:email] == "admin@pharmatransport.com" && params[:password] == "AdminPharma2026!"
      session[:mfa_pending] = true
      session[:user_email] = params[:email]
      redirect_to mfa_path, notice: "✅ Password OK → Enter MFA"
    else
      flash.now[:alert] = "❌ Invalid credentials"
      render :new, status: :unprocessable_entity
    end
  end
  
  def mfa
    redirect_to login_path unless session[:mfa_pending]
  end
  
  def verify_mfa
    if session[:mfa_pending] && params[:code] == "123456"
      session[:logged_in] = true
      session.delete(:mfa_pending)
      redirect_to root_path, notice: "🎉 Secure login complete!"
    else
      flash.now[:alert] = "❌ Wrong MFA code"
      render :mfa, status: :unprocessable_entity
    end
  end
  
  def destroy
    reset_session
    redirect_to login_path, notice: "👋 Logged out"
  end
end
