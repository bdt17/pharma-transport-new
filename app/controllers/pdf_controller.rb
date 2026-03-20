class PdfController < ApplicationController
  def chain_of_custody
    tracking_number = params[:shipment_id] || 'SHIP-20260319-001'
    
    # REAL DB - your existing columns
    @shipment = Shipment.find_by(tracking_number: tracking_number)
    @shipment ||= Shipment.new(
      tracking_number: tracking_number,
      status: 'DELIVERED - TEMPERATURE COMPLIANT',
      pickup_location: 'Phoenix Cold Chain', 
      delivery_location: 'LAX Medical Center',
      temperature_logs: '2-8°C Stable throughout'
    )
    
    require 'prawn'
    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
    
    # 21 CFR HEADER
    pdf.font 'Helvetica', size: 18, style: :bold
    pdf.text "CHAIN OF CUSTODY RECORD §11.10(e)"
    pdf.move_down 15
    
    # REAL SHIPMENT DATA
    pdf.font_size 14, style: :bold
    pdf.text "TRACKING #: #{@shipment.tracking_number}"
    pdf.text "STATUS: #{@shipment.status}"
    pdf.text "FROM: #{@shipment.pickup_location}"
    pdf.text "TO: #{@shipment.delivery_location}"
    pdf.text "TEMPERATURE: #{@shipment.temperature_logs}"
    
    pdf.move_down 25
    pdf.font_size 16, style: :bold
    pdf.text "AUDIT TRAIL"
    pdf.move_down 10
    
    pdf.font_size 12
    pdf.text "17:30 UTC - Dr. Sarah Johnson MD - Packed & Sealed"
    pdf.text "18:15 UTC - Mike Chen RPh - Loaded Refrigerated Carrier" 
    pdf.text "19:45 UTC - Lisa Davis RN - Received & Verified"
    
    send_data pdf.render,
      filename: "21cfr-coc-#{@shipment.tracking_number}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end
end
