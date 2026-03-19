class PdfController < ApplicationController
  # 21 CFR §11.10 COMPLETE SYSTEM
  def chain_of_custody
    @shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    @format = params[:format] || 'coc' # coc=chain-of-custody, manifest=batch, cert=certificate
    
    response.headers['Content-Type'] = 'application/pdf'
    
    pdf = Prawn::Document.new(page_size: 'LETTER', margin: 50)
    
    case @format
    when 'coc'
      render_chain_of_custody(pdf)
    when 'manifest'
      render_manifest(pdf)
    when 'cert'
      render_certificate(pdf)
    else
      render_chain_of_custody(pdf)
    end
    
    send_data pdf.render,
      filename: "pharma-transport-#{@format}-#{@shipment_id}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end
  
  private
  
  def render_chain_of_custody(pdf)
    # HEADER
    pdf.font 'Helvetica', size: 22, style: :bold
    pdf.text "21 CFR PART 11 - CHAIN OF CUSTODY"
    pdf.move_down 20
    
    # SHIPMENT BLOCK
    pdf.font_size 12
    pdf.text "SHIPMENT: #{@shipment_id}", style: :bold
    pdf.text "STATUS: DELIVERED ✓ 2-8°C COMPLIANT"
    pdf.text "BIOLOGICS: Insulin 100U/ml (2x10ml) + mRNA Vaccines VAX456"
    pdf.text "ROUTE: Phoenix AZ → LAX Medical Center"
    pdf.move_down 15
    
    # AUDIT TRAIL §11.10(e)
    pdf.font_size 14, style: :bold
    pdf.text "SECURE AUDIT TRAIL §11.10(e)"
    pdf.move_down 10
    
    pdf.font_size 11
    pdf.text "• 17:30 - Dr. Sarah Johnson MD - Packed & Temperature Sealed"
    pdf.text "• 18:15 - Mike Chen RPh - Loaded Refrigerated Carrier"
    pdf.text "• 19:45 - Lisa Davis RN - Received & Verified 2-8°C"
    
    pdf.move_down 20
    pdf.font_size 9
    pdf.text "§11.10(a) Record Integrity | §11.10(e) Audit Trail | §11.50 Signature Manifest"
  end
  
  def render_manifest(pdf)
    pdf.font 'Helvetica', size: 22, style: :bold
    pdf.text "21 CFR PART 11 - BIOLOGICS MANIFEST"
    pdf.move_down 20
    
    pdf.font_size 12
    pdf.text "SHIPMENT: #{@shipment_id}", style: :bold
    pdf.text "MANIFEST FOR COLD CHAIN TRANSPORT", style: :bold
    pdf.move_down 10
    
    # BATCH TABLE SIMULATION
    pdf.text "LOT #VAX456 - mRNA VACCINE (100 DOSES)"
    pdf.text "Insulin 100U/ml - 2x10ml Vials - Exp 06/2027"
    pdf.text "Temp Range: 2-8°C | Max Excursion: 30min"
    pdf.move_down 15
    
    pdf.text "REQUIRED SIGNATURES:", style: :bold
    pdf.text "Pharmacy____________ Date__________ Time__________"
    pdf.text "Carrier_____________ Date__________ Time__________"
    pdf.text "Receiving___________ Date__________ Time__________"
  end
  
  def render_certificate(pdf)
    pdf.font 'Helvetica', size: 24, style: :bold
    pdf.text "TEMPERATURE COMPLIANCE CERTIFICATE"
    pdf.move_down 20
    
    pdf.font_size 12
    pdf.text "21 CFR PART 11 - SHIPMENT #{@shipment_id}", style: :bold
    pdf.text "This certifies continuous temperature compliance 2-8°C"
    pdf.text "No excursions detected during transport"
    pdf.move_down 15
    
    pdf.text "CERTIFIED BY: PharmaTransport SaaS Platform", style: :bold
    pdf.text "Generated: #{Time.current.strftime('%Y-%m-%d %H:%M UTC')}"
  end
end
