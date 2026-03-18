class PdfJob < ApplicationJob
  queue_as :pdf_critical
  
  def perform(shipment_id)
    shipment = Shipment.find(shipment_id)
    PdfMailer.shipment_pdf(shipment).deliver_later
  end
end
