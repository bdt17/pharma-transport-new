class PdfController < ApplicationController
  def chain_of_custody
    unless session[:logged_in]
      redirect_to login_path
      return
    end
    
    require 'prawn'
    require 'prawn/table'
    
    shipment_id = params[:shipment_id] || "SHIP-#{Time.current.strftime('%Y%m%d')}-001"
    pdf = Prawn::Document.new
    
    # 21 CFR HEADER
    pdf.text "21 CFR PART 11 - CHAIN OF CUSTODY", size: 20, style: :bold
    pdf.move_down 20
    
    # SHIPMENT TABLE
    data = [["Shipment ID", shipment_id], ["User", session[:user_email]], ["Generated", Time.current.utc.to_s]]
    pdf.table(data, width: pdf.bounds.width) { row(0).background_color = "0099CC" }
    
    send_data pdf.render, filename: "chain_of_custody.pdf", type: "application/pdf", disposition: "attachment"
  end
end
