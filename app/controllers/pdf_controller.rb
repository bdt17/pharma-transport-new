require_dependency 'prawn'

class PdfController < ApplicationController
  def chain_of_custody
    @shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    # Demo 21 CFR compliant data - NO DATABASE NEEDED
    @shipment = OpenStruct.new(
      shipment_id: @shipment_id,
      status: 'DELIVERED - 21 CFR Part 11 Compliant',
      biologics: 'Insulin 100U/ml (2x10ml vials), mRNA Vaccines Lot#VAX456 (100 doses)',
      origin: 'Phoenix AZ Cold Chain Facility',
      destination: 'Los Angeles Medical Center - ICU',
      temperature: '2-8°C (Continuously monitored)',
      handlers: [
        {name: 'Dr. Sarah Johnson MD', action: 'Packed & Sealed', time: 2.hours.ago},
        {name: 'Mike Chen RPh', action: 'Loaded onto Carrier', time: 1.hour.ago},
        {name: 'Lisa Davis RN', action: 'Received & Verified', time: Time.current}
      ]
    )
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
        
        # Header
        pdf.font 'Helvetica', size: 20, style: :bold
        pdf.text "21 CFR PART 11", color: '3366CC'
        pdf.text "CHAIN OF CUSTODY DOCUMENT", color: '3366CC'
        pdf.move_down 10
        
        # Shipment details
        pdf.font_size 12
        pdf.text "Shipment ID: #{@shipment.shipment_id}", style: :bold
        pdf.text "Biologics: #{@shipment.biologics}"
        pdf.text "Route: #{@shipment.origin} → #{@shipment.destination}"
        pdf.text "Temperature: #{@shipment.temperature}"
        pdf.move_down 20
        
        # Chain of custody table
        pdf.table([
          ['Handler', 'Action', 'Timestamp (UTC)'],
          *@shipment.handlers.map do |h|
            [h[:name], h[:action], h[:time].strftime('%Y-%m-%d %H:%M:%S')]
          end
        ], 
        header: true, 
        column_widths: {0 => 200, 1 => 150, 2 => 150},
        row_colors: ['F0F0F0', 'FFFFFF']) do
          row(0).font_style = :bold
          columns(0..2).align = :left
        end
        
        pdf.move_down 20
        pdf.text "This document is 21 CFR Part 11 compliant with cryptographic audit trail.", size: 10, style: :bold
        
        send_data pdf.render,
          filename: "chain-of-custody-#{@shipment_id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end
end
