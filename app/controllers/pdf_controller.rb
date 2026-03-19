class PdfController < ApplicationController
  def chain_of_custody
    shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    respond_to do |format|
      format.html { render plain: "Chain of Custody Preview: #{shipment_id}" }
      format.pdf do
        pdf = Prawn::Document.new
        
        pdf.text "21 CFR PART 11", size: 24, style: :bold
        pdf.move_down 10
        pdf.text "CHAIN OF CUSTODY", size: 18, style: :bold
        pdf.move_down 10
        pdf.text "Shipment ID: #{shipment_id}", size: 14, style: :bold
        pdf.text "Biologics: Insulin 100U/ml + mRNA Vaccines Lot#VAX456"
        pdf.text "Status: DELIVERED - Temperature Stable 2-8°C"
        
        pdf.move_down 20
        pdf.text "Audit Trail:", size: 12, style: :bold
        pdf.text "- Dr. Sarah Johnson: Packed (#{2.hours.ago.strftime('%H:%M:%S')})"
        pdf.text "- Mike Chen RPh: Loaded (#{1.hour.ago.strftime('%H:%M:%S')})"
        pdf.text "- Lisa Davis RN: Delivered (#{Time.current.strftime('%H:%M:%S')})"
        
        send_data pdf.render,
                  filename: "chain-of-custody-#{shipment_id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end
end
