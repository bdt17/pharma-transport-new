class ShipmentsController < ApplicationController
  def pdf
    @shipment = Shipment.find(params[:id])
    
    # Your existing PDF logic (WickedPDF/Prawn)
    respond_to do |format|
      format.pdf do
        pdf = render_to_string(
          pdf: "shipment_#{@shipment.id}",
          template: "shipments/show",
          layout: "pdf"
        )
        send_data pdf, 
                  filename: "shipment #{@shipment.id} chain-of-custody.pdf",
                  type: "application/pdf",
                  disposition: "attachment"
      end
    end
  end
end
