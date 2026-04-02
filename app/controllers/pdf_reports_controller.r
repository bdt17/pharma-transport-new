# app/controllers/pdf_reports_controller.rb
class PdfReportsController < ApplicationController
  # Auth is optional; you can skip if you want this public
  # skip_before_action :authenticate_user!, only: [:show]

  def show
    respond_to do |format|
      format.html { render plain: "biologics / pdf stub" }
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
      # Important: explicitly render nothing for other formats so response is not empty
      format.* { head :not_acceptable }
    end
  end
end
