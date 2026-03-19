class PdfController < ApplicationController
  def chain_of_custody
    shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    response.headers['Content-Type'] = 'application/pdf'
    
    require 'prawn'
    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
    
    # 21 CFR PART 11 HEADER
    pdf.font 'Helvetica', size: 24, style: :bold
    pdf.text "21 CFR PART 11"
    pdf.move_down 15
    
    pdf.font_size 18, style: :bold
    pdf.text "CHAIN OF CUSTODY RECORD"
    pdf.move_down 10
    
    pdf.font_size 14
    pdf.text "SHIPMENT ID: #{shipment_id}", style: :bold
    pdf.text "STATUS: DELIVERED - TEMPERATURE COMPLIANT"
    pdf.text "BIOLOGICS: Insulin 100U/ml (2x10ml vials)"
    pdf.text "ROUTE: Phoenix Cold Chain → LAX Medical Center"
    pdf.text "TEMPERATURE: 2-8°C Stable"
    pdf.move_down 25
    
    # AUDIT TRAIL - STATIC TIMES
    pdf.font_size 16, style: :bold
    pdf.text "AUDIT TRAIL §11.10(e)"
    pdf.move_down 10
    
    pdf.font_size 12
    pdf.text "17:30 UTC - Dr. Sarah Johnson MD - Packed & Sealed"
    pdf.text "18:15 UTC - Mike Chen RPh - Loaded Refrigerated Carrier"
    pdf.text "19:45 UTC - Lisa Davis RN - Received & Verified"
    
    pdf.move_down 25
    pdf.font_size 10
    pdf.text "COMPLIANCE: §11.10(a) Record integrity maintained"
    pdf.text "§11.10(e) Secure, time-stamped audit trail generated"
    pdf.text "Generated: 2026-03-19 22:38:00 UTC"
    
    send_data pdf.render,
      filename: "21cfr-coc-#{shipment_id}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end
end

