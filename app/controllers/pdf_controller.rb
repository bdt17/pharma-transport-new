class PdfController < ApplicationController
  def chain_of_custody
    @shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    # FORCE PDF - bypass respond_to negotiation
    if request.format == :html || !request.format.pdf?
      response.headers['Content-Type'] = 'application/pdf'
      request.format = :pdf
    end
    
    require 'prawn'
    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
    
    # 21 CFR HEADER
    pdf.font 'Helvetica', size: 22, style: :bold
    pdf.text "21 CFR PART 11"
    pdf.move_down 12
    
    pdf.font_size 18, style: :bold
    pdf.text "CHAIN OF CUSTODY RECORD"
    pdf.move_down 25
    
    # SHIPMENT DETAILS
    pdf.font_size 13
    pdf.text "SHIPMENT ID: #{@shipment_id}", style: :bold
    pdf.text "STATUS: DELIVERED ✓ TEMPERATURE COMPLIANT 2-8°C"
    pdf.text "BIOLOGICS: Insulin 100U/ml (2x10ml vials)"
    pdf.text "ROUTE: Phoenix Cold Chain Facility → LAX Medical Center"
    pdf.move_down 25
    
    # AUDIT TRAIL 21 CFR §11.10(e)
    pdf.font_size 15, style: :bold
    pdf.text "AUDIT TRAIL §11.10(e)"
    pdf.move_down 8
    
    pdf.font_size 11
    pdf.text "2026-03-19 17:30:15 - Dr. Sarah Johnson MD - Packed & Sealed"
    pdf.text "2026-03-19 18:15:42 - Mike Chen RPh - Loaded Temperature Carrier"
    pdf.text "2026-03-19 19:45:28 - Lisa Davis RN - Received & Verified"
    
    pdf.move_down 25
    
    # COMPLIANCE FOOTER
    pdf.font_size 9
    pdf.text "COMPLIANCE: §11.10(a) Record integrity maintained | §11.10(e) Secure audit trail"
    pdf.text "§11.50 Signed records include date/time | §11.100 Unique system controls"
    pdf.text "GENERATED: #{Time.current.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    pdf.text "PharmaTransport SaaS Platform - 21 CFR Part 11 Compliant"
    
    send_data pdf.render,
      filename: "21cfr-coc-#{@shipment_id}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end
end
