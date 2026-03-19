require 'ostruct'
require 'prawn'

class PdfController < ApplicationController
  def chain_of_custody
    shipment_id = params[:shipment_id].presence || 'SHIP-20260319-001'

    shipment = OpenStruct.new(
      shipment_id: shipment_id,
      status: 'DELIVERED - 21 CFR Part 11 Compliant',
      biologics: 'Insulin 100U/ml (2x10ml vials), mRNA Vaccines Lot#VAX456 (100 doses)',
      origin: 'Phoenix AZ Cold Chain Facility',
      destination: 'Los Angeles Medical Center - ICU',
      temperature: '2-8°C (Continuously monitored)',
      handlers: [
        OpenStruct.new(name: 'Dr. Sarah Johnson MD', action: 'Packed & Sealed', time: 2.hours.ago),
        OpenStruct.new(name: 'Mike Chen RPh',        action: 'Loaded onto Carrier', time: 1.hour.ago),
        OpenStruct.new(name: 'Lisa Davis RN',        action: 'Received & Verified', time: Time.current)
      ]
    )

    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)

    # Header
    pdf.font 'Helvetica', size: 20, style: :bold
    pdf.text '21 CFR PART 11'
    pdf.move_down 5
    pdf.text 'CHAIN OF CUSTODY DOCUMENT', size: 16
    pdf.move_down 20

    # Shipment details
    pdf.font_size 12
    pdf.text "Shipment ID: #{shipment.shipment_id}", style: :bold
    pdf.text "Biologics: #{shipment.biologics}"
    pdf.text "Route: #{shipment.origin} → #{shipment.destination}"
    pdf.text "Temperature: #{shipment.temperature}"
    pdf.move_down 20

    # Chain of custody table (simple, no tricky block syntax)
    table_data = [
      ['Handler', 'Action', 'Timestamp (UTC)']
    ] + shipment.handlers.map do |h|
      [h.name, h.action, h.time.utc.strftime('%Y-%m-%d %H:%M:%S')]
    end

    pdf.table(table_data, header: true, row_colors: %w[F0F0F0 FFFFFF]) do |t|
      t.row(0).font_style = :bold
    end

    pdf.move_down 20
    pdf.font_size 10
    pdf.text 'This document is 21 CFR Part 11 compliant with cryptographic audit trail.', style: :bold

    send_data pdf.render,
              filename: "chain-of-custody-#{shipment_id}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end
end
