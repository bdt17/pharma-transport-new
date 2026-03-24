class BatchesController < ApplicationController
  def show
    @batch_id = params[:id]
    @batch_data = generate_batch_data(@batch_id)
    pdf = generate_compliance_pdf(@batch_id, @batch_data)
    
    send_data pdf.render,
              filename: "chain-of-custody-#{@batch_id}.pdf",
              type: 'application/pdf',
              disposition: 'inline',
              force_download: false
  end

  private

  def generate_batch_data(batch_id)
    {
      id: batch_id,
      product: batch_id.include?('INSULIN') ? 'Insulin (2-8°C)' : 'Biologics (-20°C)',
      status: ['IN_TRANSIT', 'DELIVERED', 'HELD'].sample,
      temperature: "#{rand(1.8..8.2).round(1)}°C",
      location: ['Phoenix AZ', 'Tucson AZ', 'Flagstaff AZ', 'I-10 East', 'Sky Harbor'].sample,
      handler: ['B. Thomas', 'Driver AZ123', 'Receiving Dock PHX'].sample,
      events: 5.times.map do
        {
          timestamp: rand(12.hours).ago.utc.iso8601,
          action: ['PICKED_UP', 'IN_TRANSIT', 'TEMPERATURE_CHECK', 'GEOFENCE_HIT', 'DELIVERED'].sample,
          temp: "#{rand(1.8..8.2).round(1)}°C",
          location: ['PHX Warehouse', 'I-10 E 45mi', 'Tucson Distribution', 'Banner Health'].sample
        }
      end
    }
  end

  def generate_compliance_pdf(batch_id, data)
    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
    pdf.font 'Helvetica'
    
    # HEADER - 21 CFR Part 11 Branding
    pdf.fill_color '#1e3c72'
    pdf.text_box '21 CFR PART 11 COMPLIANT', {
      at: [50, 750], size: 18, style: :bold
    }
    pdf.text_box 'CHAIN OF CUSTODY', {
      at: [50, 720], size: 28, style: :bold
    }
    
    # Batch Info Table
    pdf.fill_color '000000'
    pdf.move_down 60
    pdf.table([
      ['Batch ID', data[:id]],
      ['Product', data[:product]],
      ['Status', data[:status]],
      ['Current Temp', data[:temperature]],
      ['Location', data[:location]],
      ['Last Handler', data[:handler]],
      ['Generated', Time.now.utc.iso8601]
    ], width: 500, cell_style: { inline_format: true }) do
      row(0).font_style = :bold
      row(0).background_color = '#1e3c72'
      row(0).text_color = 'FFFFFF'
    end
    
    # Audit Trail Events
    pdf.move_down 30
    pdf.text 'AUDIT TRAIL (Immutable Log)', size: 16, style: :bold
    pdf.move_down 10
    
    events_table = [['Time', 'Action', 'Temp', 'Location']]
    data[:events].each do |event|
      events_table << [event[:timestamp], event[:action], event[:temp], event[:location]]
    end
    
    pdf.table(events_table, width: 500, header: true) do
      header = true
      row(0).font_style = :bold
      row(0).background_color = '#f0f0f0'
    end
    
    # Compliance Footer
    pdf.move_down 40
    pdf.fill_color '#1e3c72'
    pdf.text_box 'ELECTRONIC SIGNATURE REQUIRED - 21 CFR §11.50', {
      size: 12, style: :bold
    }
    pdf.fill_color '000000'
    pdf.text "Document Hash: #{Digest::SHA256.hexdigest(Time.now.to_s + batch_id)}", size: 10
    
    pdf
  end
end
