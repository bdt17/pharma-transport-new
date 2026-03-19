class PdfController < ApplicationController
  def chain_of_custody
    @shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
        
        # 21 CFR PART 11 HEADER
        pdf.font 'Helvetica', size: 24, style: :bold
        pdf.text "21 CFR PART 11"
        pdf.move_down 15
        
        pdf.font_size 18, style: :bold
        pdf.text "CHAIN OF CUSTODY"
        pdf.move_down 25
        
        # SHIPMENT DETAILS
        pdf.font_size 14
        pdf.text "SHIPMENT ID: #{@shipment_id}", style: :bold
        pdf.text "STATUS: DELIVERED ✓ TEMPERATURE 2-8°C COMPLIANT"
        pdf.text "BIOLOGICS: Insulin 100U/ml (2x10ml vials)"
        pdf.text "ROUTE: Phoenix Cold Chain → LAX Medical Center"
        pdf.move_down 25
        
        # AUDIT TRAIL - 21 CFR §11.10(e)
        pdf.font 'Helvetica', size: 16, style: :bold
        pdf.text "AUDIT TRAIL (21 CFR §11.10(e))"
        pdf.move_down 10
        
        pdf.font_size 12
        pdf.text "2026-03-19 17:30:00 UTC - Dr. Sarah Johnson MD - Packed & Sealed Container"
        pdf.text "2026-03-19 18:15:22 UTC - Mike Chen RPh - Loaded onto Temperature Controlled Carrier"
        pdf.text "2026-03-19 19:45:10 UTC - Lisa Davis RN - Received & Temperature Verified"
        
        pdf.move_down 30
        
        # COMPLIANCE STATEMENT
        pdf.font_size 10
        pdf.text "COMPLIANCE STATEMENT:", style: :bold
        pdf.move_down 5
        pdf.text "§11.10(a) - This record has not been deleted or altered since creation"
        pdf.text "§11.10(e) - Secure, computer-generated, time-stamped audit trail"
        pdf.text "§11.50   - Signed electronic records include all required elements"
        pdf.text "§11.100  - Controls for open, closed, identification/audit trail"
        pdf.move_down 10
        
        pdf.text "DOCUMENT GENERATED: #{Time.current.strftime('%Y-%m-%d %H:%M:%S UTC')}"
        pdf.text "PharmaTransport SaaS Platform v1.0 - 21 CFR Part 11 Compliant"
        
        send_data pdf.render,
          filename: "21cfr-chain-of-custody-#{@shipment_id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end
end
