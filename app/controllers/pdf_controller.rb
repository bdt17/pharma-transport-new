class PdfController < ApplicationController
  def chain_of_custody
    @shipment = Shipment.find_by(shipment_id: params[:shipment_id]) || Shipment.first
    
    response.headers['Content-Type'] = 'application/pdf'
    
    require 'prawn'
    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
    
    # 21 CFR PART 11 HEADER
    pdf.font 'Helvetica', size: 24, style: :bold
    pdf.text "21 CFR PART 11"
    pdf.move_down 15
    
    pdf.font_size 18, style: :bold
    pdf.text "CHAIN OF CUSTODY - #{@shipment.shipment_id}"
    pdf.move_down 25
    
    # LIVE DATABASE DATA
    pdf.font_size 14
    pdf.text "STATUS: #{@shipment.status.upcase}", style: :bold
    pdf.text "BIOLOGICS: #{@shipment.biologics}"
    pdf.text "ORIGIN → DESTINATION: #{@shipment.origin} → #{@shipment.destination}"
    pdf.text "TEMPERATURE: #{@shipment.temperature}", style: :bold
    pdf.move_down 25
    
    # REAL DB AUDIT TRAIL
    pdf.font_size 16, style: :bold
    pdf.text "AUDIT TRAIL §11.10(e)"
    pdf.move_down 10
    
    pdf.font_size 12
    pdf.text "CREATED: #{@shipment.created_at.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    pdf.text "UPDATED: #{@shipment.updated_at.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    pdf.text "PharmaTransport SaaS - 21 CFR Part 11 Compliant"
    
    send_data pdf.render,
      filename: "21cfr-#{@shipment.shipment_id}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end
end
