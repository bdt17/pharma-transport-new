class PdfController < ApplicationController
  def chain_of_custody
    shipment_id = params[:shipment_id] || 'SHIP-20260320-001'
    response.headers['Content-Type'] = 'application/pdf'
    pdf_content = generate_pdf_content(shipment_id)
    send_data pdf_content,
      filename: "21cfr-coc-#{shipment_id}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end

  private

  def generate_pdf_content(shipment_id)
    <<-PDF
%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >>
endobj
4 0 obj
<< /Length 1000 >>
stream
BT
/Helvetica 24 Tf 72 720 Td (21 CFR PART 11) Tj ET
/Helvetica 18 Tf 72 680 Td (CHAIN OF CUSTODY) Tj ET
/Helvetica 14 Tf 72 640 Td (TRACKING: #{shipment_id}) Tj ET
72 600 Td (STATUS: DELIVERED - 2-8C COMPLIANT) Tj ET
72 560 Td (ROUTE: Phoenix Cold Chain -> LAX Medical) Tj ET
72 520 Td (BIOLOGICS: Insulin 100U/ml) Tj ET
72 480 Td (AUDIT TRAIL §11.10(e):) Tj ET
72 440 Td (17:30 Dr. Sarah Johnson - Packed) Tj ET
72 400 Td (18:15 Mike Chen RPh - Loaded) Tj ET
72 360 Td (19:45 Lisa Davis RN - Delivered) Tj ET
ET
endstream
endobj
5 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj
xref
0 6
0000000000 65535 f 
0000000010 00000 n 
0000000075 00000 n 
0000000178 00000 n 
0000000289 00000 n 
0000000362 00000 n 
trailer
<< /Size 6 /Root 1 0 R >>
startxref
450
%%EOF
    PDF
  end
end
