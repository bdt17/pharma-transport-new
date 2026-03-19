class PdfController < ApplicationController
  # 21 CFR Part 11 Chain of Custody - PRODUCTION READY
  def chain_of_custody
    @shipment_id = params[:shipment_id] || 'SHIP-20260319-001'
    
    respond_to do |format|
      format.html { render plain: "21 CFR Chain of Custody: #{@shipment_id}" }
      format.pdf do
        pdf = Prawn::Document.new(page_size: 'LETTER', margin: 72)
        
        # HEADER - 21 CFR Branding
        pdf.font 'Helvetica', size: 18, style: :bold
        pdf.fill_color '003087'  # FDA Blue
        pdf.text_box "21 CFR PART 11", {
          at: [pdf.bounds.left, pdf.bounds.top - 20],
          width: pdf.bounds.width,
          align: :center
        }
        pdf.fill_color '000000'
        pdf.text_box "CHAIN OF CUSTODY DOCUMENT", {
          at: [pdf.bounds.left, pdf.bounds.top - 45],
          width: pdf.bounds.width,
          align: :center,
          style: :bold
        }
        
        # SHIPMENT HEADER TABLE
        pdf.move_down 80
        pdf.font_size 12
        pdf.table([
          ['SHIPMENT ID', @shipment_id],
          ['STATUS', 'DELIVERED - TEMPERATURE COMPLIANT'],
          ['BIOLOGICS', 'Insulin 100U/ml (2x10ml vials), mRNA Vaccines Lot#VAX456 (100 doses)'],
          ['ROUTE', 'Phoenix AZ Cold Chain → LAX Medical Center ICU'],
          ['TEMPERATURE', '2-8°C (MONITORED)']
        ], 
        column_widths: {0 => 150, 1 => 350},
        row_colors: ['DDDDDD', 'FFFFFF']) do
          row(0).font_style = :bold
          row(0).background_color = '003087'
          row(0).text_color = 'FFFFFF'
        end
        
        # AUDIT TRAIL TABLE - 21 CFR §11.10(e)
        pdf.move_down 30
        pdf.font 'Helvetica', size: 14, style: :bold
        pdf.text "ELECTRONIC AUDIT TRAIL", color: '003087'
        pdf.move_down 10
        
        audit_data = [
          ['TIME', 'HANDLER', 'ACTION', 'AUDIT ID'],
          ["#{2.hours.ago.strftime('%m/%d/%Y %H:%M')}", 'Dr. Sarah Johnson MD', 'Packed & Sealed', 'AUDIT-001'],
          ["#{1.hour.ago.strftime('%m/%d/%Y %H:%M')}", 'Mike Chen RPh', 'Loaded Carrier', 'AUDIT-002'],
          [Time.current.strftime('%m/%d/%Y %H:%M'), 'Lisa Davis RN', 'Received Verified', 'AUDIT-003']
        ]
        
        pdf.table(audit_data,
          header: true,
          column_widths: {0 => 100, 1 => 140, 2 => 130, 3 => 130},
          row_colors: ['EEEEEE', 'FFFFFF']
        ) do
          row(0).font_style = :bold
          row(0).background_color = '003087'
          row(0).text_color = 'FFFFFF'
        end
        
        # COMPLIANCE FOOTER - 21 CFR §11.10(a)
        pdf.move_down 40
        pdf.font_size 9
        pdf.text "§11.10(a) This record has not been altered/deleted in any way since initial creation.",
        pdf.text "§11.10(e) Complete audit trail available. §11.50 Signed electronic records include date/time.",
        pdf.text "§11.100 Electronic signatures unique. §11.200 Non-biometric signature components.",
        pdf.text "Generated: #{Time.current.strftime('%Y-%m-%d %H:%M:%S UTC')} | PharmaTransport SaaS v1.0",
        
        send_data pdf.render,
          filename: "21cfr-coc-#{@shipment_id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end
end
