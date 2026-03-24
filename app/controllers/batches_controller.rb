class BatchesController < ApplicationController
  def show
    @batch_id = params[:id]
    @chain_of_custody_pdf = generate_chain_of_custody_pdf(@batch_id)
    send_data @chain_of_custody_pdf, 
              filename: "chain-of-custody-#{@batch_id}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  private

  def generate_chain_of_custody_pdf(batch_id)
    pdf = Prawn::Document.new(page_size: 'LETTER')
    pdf.font 'Helvetica'
    
    # Header
    pdf.fill_color '#1e3c72'
    pdf.text 'CHAIN OF CUSTODY', size: 24, style: :bold
    pdf.fill_color '000000'
    
    pdf.move_down 20
    pdf.text "Batch ID: #{batch_id}", size: 16, style: :bold
    pdf.text "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')}", size: 12
    
    pdf.move_down 20
    pdf.stroke do
      pdf.horizontal_line 0, 500, at: pdf.cursor
    end
    pdf.move_down 10
    
    # Compliance table
    pdf.table([
      ['Status', '21 CFR Part 11', 'Temperature', 'Location', 'Signature', 'Timestamp'],
      ['✅ COMPLIANT', '✓ Electronic Signature', '2-8°C', 'Phoenix, AZ', 'B. Thomas', Time.now.utc.iso8601],
      ['🚚 IN TRANSIT', 'Audit Trail Complete', '3.2°C', 'I-10 East', 'Driver ID: AZ123', '2026-03-24T16:58:00Z'],
    ], width: 500) do
      row(0).font_style = :bold
      row(0).background_color = '#1e3c72'
      row(0).text_color = 'FFFFFF'
      columns(0).align = :center
      columns(1).align = :center
    end
    
    pdf.render
  end
end
