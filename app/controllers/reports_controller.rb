class ReportsController < ApplicationController
  def compliance
    # Minimal Prawn PDF - no extra requires that break Zeitwerk
    pdf = Prawn::Document.new
    pdf.text "21 CFR Part 11 Compliance Report"
    pdf.text "Thomas IT Pharma Transport SaaS"
    pdf.text "Batch 123456: 2-8°C ✓ Compliant"
    
    send_data pdf.render, 
              filename: "compliance.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
end
