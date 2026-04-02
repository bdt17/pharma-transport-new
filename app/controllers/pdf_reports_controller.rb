# app/controllers/pdf_reports_controller.rb
class PdfReportsController < ApplicationController
  # If you want public /pdf, remove this
  # before_action :authenticate_user!

  def show
    respond_to do |format|
      format.pdf do
        require 'prawn'
        pdf = Prawn::Document.new
        pdf.text "THOMAS IT PHARMA TRANSPORT - PDF SERVICE (demo)"
        pdf.text "Type: #{params[:type]}"
        pdf.text "Demo: #{params[:demo]}"

        send_data pdf.render,
          filename: "pharma-demo-#{params[:type] || 'generic'}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end
      # For any other format (HTML, JSON, etc.), send 406 Not Acceptable
      format.* { head :not_acceptable }
    end
  end
end
