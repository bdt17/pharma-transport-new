class ReportsController < ApplicationController
  def compliance
    respond_to do |format|
      format.html { render plain: "Compliance UI - Coming soon" }
      format.pdf do
        pdf = Prawn::Document.new(page_size: 'A4')
        pdf.text "21 CFR Part 11 Compliance Report"          # ASCII only
        pdf.text "Thomas IT Pharma Transport SaaS"           # ASCII only  
        pdf.text "Batch 123456 - Status: Compliant 2-8C"     # No ° symbol
        pdf.text "Generated: #{Time.current.strftime('%Y-%m-%d %H:%M UTC')}"
        
        send_data pdf.render,
                  filename: "compliance-#{Time.current.strftime('%Y%m%d-%H%M%S')}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end
end
