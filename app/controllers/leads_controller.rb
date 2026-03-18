class LeadsController < ApplicationController
  def create
    email = params[:email]
    company = params[:company] || 'N/A'
    
    # EMAIL TO YOUR PERSONAL (brett@thomasit.com)
    LeadMailer.demo_request(email, company).deliver_now
    
    redirect_to root_path, notice: "✅ Thanks! Demo access sent to #{email}"
  end
end
