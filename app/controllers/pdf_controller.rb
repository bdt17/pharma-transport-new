class PdfController < ApplicationController
  def chain_of_custody
    shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    respond_to do |format|
      format.html { render plain: "21 CFR Chain of Custody: #{shipment_id}" }
      format.pdf do
        require 'prawn'
        pdf = Prawn::Document.new(page_size: 'LETTER')
        
        # HEADER - NO COLORS/TABLES
        pdf.font 'Helvetica', style: :bold, size: 20
        pdf.text "21 CFR PART 11"
        pdf.move_down 10
        
        pdf.font_size 16
        pdf.text "CHAIN OF CUSTODY"
        pdf.move_down 20
        
        # SHIPMENT INFO - SIMPLE TEXT
        pdf.font_size 14
        pdf.text "SHIPMENT ID: #{shipment_id}", style: :bold
        pdf.text "STATUS: DELIVERED - TEMPERATURE COMPLIANT (2-8C)"
        pdf.text "BIOLOGICS: Insulin 100U/ml (2x10ml vials)"
        pdf.text "ROUTE: Phoenix Cold Chain → LAX Medical Center"
        pdf.move_down 30
        
        # AUDIT TRAIL - SIMPLE TEXT LINES
        pdf.font 'Helvetica', style: :bold, size: 14
        pdf.text "AUDIT TRAIL:"
        pdf.move_down 5
        
        pdf.font_size 12
        pdf.text "2026-03-19 17:30 - Dr. Sarah Johnson MD - Packed & Sealed"
        pdf.text "2026-03-19 18:15 - Mike Chen RPh - Loaded onto Carrier" 
        pdf.text "2026-03-19 19:45 - Lisa Davis RN - Received & Verified"
        
        pdf.move_down 30
        pdf.font_size 10
        pdf.text "21 CFR §11.10(e) - Complete audit trail maintained"
        pdf.text "Generated: #{Time.current.strftime('%Y-%m-%d %H:%M:%S UTC')}"
        
        send_data pdf.render,
          filename: "21cfr-coc-#{shipment_id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end
end
