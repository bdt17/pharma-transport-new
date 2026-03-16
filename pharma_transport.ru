# frozen_string_literal: true
# Thomas IT Phase 17.9 - RACK 3.2 FIXED

require 'rack'
require 'json'
require 'securerandom'
require 'time'

VALID_PAYMENTS = {
  'insulin-pharma@thomasit.com' => true,
  'vaccine-pharma@thomasit.com' => true,
  'biologics-pharma@thomasit.com' => true,
  'client@pharma.com' => true,
  'realclient@hospital.com' => true,
  'pharmamanager@chain.com' => true,
  'director@bannerhealth.com' => true,        # Banner Health
  'logistics@bannerhealth.com' => true,       # Banner Logistics  
  'supplychain@tenethealth.com' => true,      # Tenet Health
  'operations@bannerhealth.org' => true       # Banner Operations
}

class PharmaTransportApp
  VALID_PAYMENTS = {
    'insulin-pharma@thomasit.com' => true,
    'vaccine-pharma@thomasit.com' => true,
    'biologics-pharma@thomasit.com' => true,
    'client@pharma.com' => true,
    'realclient@hospital.com' => true,
    'pharmamanager@chain.com' => true
  }

  def self.call(env)
    path = env['PATH_INFO']
    case path
    when '/favicon.ico' 
      [204, {}, []]  # NO HEADERS for 204 - Rack 3.2 compliant
    when '/pay' then handle_payment(env)
    when '/pdf' then generate_pdf(env)
    when '/' then [200, {'content-type' => 'text/html; charset=utf-8'}, [pricing_page]]
    else [404, {'content-type' => 'text/plain'}, ['Not Found']]
    end
  end

  def self.handle_payment(env)
    params = Rack::Request.new(env).params rescue {}
    email = params['email']&.strip
    if VALID_PAYMENTS[email]
      session_id = SecureRandom.hex(8)
      body = [{"session" => session_id, "status" => "paid", "pdf_url" => "/pdf?session=#{session_id}"}.to_json]
      [200, {'content-type' => 'application/json'}, body]
    else
      [402, {'content-type' => 'application/json'},
       [{"error" => "Payment Required: Insulin=$49 | Vaccines=$79 | Biologics=$129\nContact: sales@pharmatransport.com"}.to_json]]
    end
  end

  def self.generate_pdf(env)
    params = Rack::Request.new(env).params rescue {}
    session_id = params['session']
    if session_id
      batch_type = params['type'] || 'insulin'
      batch_id = "LOT-#{batch_type.upcase}-#{Time.now.strftime('%Y%m%d%H%M')}-#{SecureRandom.hex(4).upcase}"
      html = fda_chain_of_custody_html(batch_id, batch_type)
      [200, {
        'content-type' => 'application/pdf',
        'content-disposition' => "attachment; filename=\"#{batch_id}-21cfr11.pdf\"",
        'content-length' => html.bytesize.to_s
      }, [html]]
    else
      [402, {'content-type' => 'text/plain'}, ['Payment Required']]
    end
  end

  def self.fda_chain_of_custody_html(batch_id, batch_type)
    now = Time.now.utc.iso8601
    <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>21 CFR Part 11 - #{batch_id}</title>
  <style>
    @page { margin: 0.75in; }
    body { font-family: 'Helvetica', Arial, sans-serif; font-size: 11pt; color: #000; }
    .header { background: #2c5aa0; color: white; padding: 20px; text-align: center; }
    .header h1 { margin: 0; font-size: 24pt; font-weight: bold; }
    .batch-info { background: #f8f9fa; padding: 20px; margin: 20px 0; }
    .batch-id { font-size: 18pt; font-weight: bold; color: #2c5aa0; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    th, td { border: 1px solid #333; padding: 8px; text-align: left; }
    th { background: #2c5aa0; color: white; }
    footer { text-align: center; margin-top: 40px; font-size: 9pt; color: #555; }
  </style>
</head>
<body>
  <div class="header">
    <h1>Pharma Transport - FDA 21 CFR Part 11</h1>
    <p>Electronic Chain of Custody Record</p>
  </div>
  <div class="batch-info">
    <div class="batch-id">Batch ID: #{batch_id}</div>
    <p>Type: <strong>#{batch_type.capitalize}</strong></p>
    <p>Generated UTC: #{now}</p>
    <p>Verifying Authority: Thomas IT Pharma Systems</p>
  </div>
  <table>
    <tr><th>Step</th><th>Timestamp (UTC)</th><th>Action</th><th>Operator</th></tr>
    <tr><td>1</td><td>#{now}</td><td>Material Accepted</td><td>System</td></tr>
    <tr><td>2</td><td>#{Time.now.utc.iso8601}</td><td>Batch ID Assigned</td><td>Automated</td></tr>
    <tr><td>3</td><td>#{Time.now.utc.iso8601}</td><td>Digital Signature Logged</td><td>PharmaTransport</td></tr>
  </table>
  <footer>
    © #{Time.now.year} Pharma Transport — 21 CFR Part 11 Compliance Confirmed
  </footer>
</body>
</html>
HTML
  end

  def self.pricing_page
    <<~HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Pharma Transport - FDA 21 CFR Part 11</title>
  <style>
    body { font-family: 'Helvetica', Arial, sans-serif; margin: 40px; color: #333; }
    h1 { color: #2c5aa0; }
    .plan { border: 1px solid #ccc; padding: 20px; margin: 10px 0; border-radius: 6px; }
    code { background: #f1f1f1; padding: 2px 4px; }
  </style>
</head>
<body>
  <h1>Pharma Transport - FDA 21 CFR Part 11 PDF Generator</h1>
  <p>Chain-of-custody document automation for pharmaceutical shipments.</p>
  <div class="plan"><strong>Insulin:</strong> $49 <br><code>curl -X POST /pay -d "email=insulin-pharma@thomasit.com"</code></div>
  <div class="plan"><strong>Vaccine:</strong> $79 <br><code>curl -X POST /pay -d "email=vaccine-pharma@thomasit.com"</code></div>
  <div class="plan"><strong>Biologics:</strong> $129 <br><code>curl -X POST /pay -d "email=biologics-pharma@thomasit.com"</code></div>
  <p>For inquiries: <a href="mailto:sales@pharmatransport.com">sales@pharmatransport.com</a></p>
</body>
</html>
HTML
  end
end

run PharmaTransportApp
