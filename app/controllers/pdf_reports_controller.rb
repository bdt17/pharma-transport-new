class PdfReportsController < ApplicationController
  def show
    # 1. For /pdf?type=biologics&demo=1, render a real PDF
    if params[:type] == "biologics" && params[:demo] == "1"
      require 'prawn'

      pdf = Prawn::Document.new
      pdf.text "Thomas IT - CoC / Biologics Demo PDF", size: 18, style: :bold
      pdf.text "Type: #{params[:type] || 'unknown'}"
      pdf.text "Demo: #{params[:demo] || 'N/A'}"
      pdf.text "SHA256: #{Digest::SHA256.hexdigest(Time.now.to_s)}"
      pdf.text "Generated: #{Time.now.utc.iso8601}"

      send_data pdf.render,
                filename: "biologics-demo.pdf",
                type: "application/pdf",
                disposition: "inline"
    else
      # 2. Fallback for plain /pdf request (still 200)
      render plain: "CoC / biologics PDF endpoint (Phase 11)", status: 200
    end
  end
end
