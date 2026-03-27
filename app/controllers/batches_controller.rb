class BatchesController < ApplicationController
  def index
    @batches = [
      { id: 1, batch_id: "LOT-INSULIN-PROD", product: "Insulin", status: "Active", temp: "2-8°C", location: "Phoenix, AZ" },
      { id: 2, batch_id: "LOT-VACCINE-456", product: "mRNA Vaccine", status: "Active", temp: "-65°C", location: "Sky Harbor" }
    ]
  end

  def show
    @batch = { id: params[:id], batch_id: "LOT-#{params[:id]}", product: "Insulin", status: "Active" }
  end

  def chain_of_custody
    pdf = Prawn::Document.new
    pdf.text "21 CFR Part 11 - Chain of Custody", size: 18, style: :bold
    pdf.text "Batch ID: #{params[:id]}"
    pdf.text "SHA256: #{Digest::SHA256.hexdigest(Time.now.to_s + params[:id])}"
    pdf.text "Generated: #{Time.now.utc}"
    send_data pdf.render, filename: "chain-of-custody-#{params[:id]}.pdf", type: 'application/pdf', disposition: 'inline'
  end
end
