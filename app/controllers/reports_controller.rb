require 'prawn/table'
require 'prawn/measurement_extensions'

class ReportsController < ApplicationController
  def compliance
    # Demo pharma batch data (replace with Batch model query)
    batches = [
      {id: 123456, product: "Insulin", temp: "2-8°C", status: "Compliant", custodian: "B. Thomas", timestamp: Time.current.strftime("%Y-%m-%d %H:%M UTC")}
    ]
    
    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 72)
    
    # Title & Header
    pdf.font_size 20
    pdf.text "21 CFR Part 11 Compliance Report", style: :bold, align: :center
    pdf.font_size 14
    pdf.text "Thomas IT Pharma Transport SaaS Platform", align: :center
    pdf.text "Chain of Custody & Cold Chain Verification", align: :center
    
    pdf.move_down 30
    
    # Data Table
    table_data = [["Batch ID", "Product", "Temp Range", "Status", "Custodian", "Timestamp"]]
    batches.each do |b|
      table_data << [b[:id], b[:product], b[:temp], b[:status], b[:custodian], b[:timestamp]]
    end
    
    pdf.table(table_data, 
              header: true, 
              width: pdf.bounds.width,
              column_widths: {0 => 60, 1 => 80, 2 => 70, 3 => 70, 4 => 100, 5 => 120}) do
      row(0).font_style = :bold
      row(0).background_color = "3366CC"
      row(0).text_color = "FFFFFF"
      cells.border_lines = [:stroke]
      cells.padding = 8
    end
    
    # Compliance Statement
    pdf.move_down 40
    pdf.font_size 12
    pdf.text_box "This report certifies compliance with 21 CFR Part 11 electronic records and signatures requirements. All data is GPS-tracked and tamper-evident.", 
                 at: [pdf.bounds.left, pdf.cursor], width: pdf.bounds.width, align: :justify
    
    # Footer
    pdf.go_to_page(pdf.page_count)
    pdf.font_size 10
    pdf.draw_text "Generated: #{Time.current.strftime("%Y-%m-%d %H:%M:%S UTC")}", at: [pdf.bounds.left, pdf.bounds.bottom + 20]
    pdf.draw_text "© 2026 Thomas IT. Confidential.", at: [pdf.bounds.right - 200, pdf.bounds.bottom + 20]
    
    send_data pdf.render, 
              filename: "pharma-compliance-report-#{Time.current.to_i}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
end
