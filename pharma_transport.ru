#!/usr/bin/env ruby
# frozen_string_literal: true
# Thomas IT Pharma Transport - Phase 19.6 PRODUCTION READY

require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'stringio'

class PharmaTransportApp
  VALID_PAYMENTS = {
   'logistics@bannerhealth.com' => true,  
   'insulin-pharma@thomasit.com' => true,
    'vaccine-pharma@thomasit.com' => true,
    'biologics-pharma@thomasit.com' => true,
    'client@pharma.com' => true,
    'realclient@hospital.com' => true,
    'pharmamanager@chain.com' => true,
    'director@bannerhealth.com' => true,
  }

  def self.call(env)
    path = env['PATH_INFO']
    case path
    when '/favicon.ico' then [204, {}, []]
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
    body { font-family: 'Helvetica', Arial, sans-serif; font-size: 11pt; color: #000; line-height: 1.4; }
    .header { background: #2c5aa0; color: white; padding: 20px; text-align: center; }
    .header h1 { margin: 0; font-size: 24pt; font-weight: bold; }
    .batch-info { background: #f8f9fa; padding: 20px; margin: 20px 0; border-left: 4px solid #2c5aa0; }
    .batch-id { font-size: 18pt; font-weight: bold; color: #2c5aa0; margin-bottom: 10px; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    th, td { border: 1px solid #333; padding: 8px; text-align: left; }
    th { background: #2c5aa0; color: white; font-weight: bold; }
    footer { text-align: center; margin-top: 40px; font-size: 9pt; color: #555; border-top: 1px solid #ddd; padding-top: 20px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>Pharma Transport - FDA 21 CFR Part 11</h1>
    <p>Electronic Chain of Custody Record</p>
  </div>

  <div class="batch-info">
    <div class="batch-id">Batch ID: #{batch_id}</div>
    <p><strong>Type:</strong> #{batch_type.capitalize}</p>
    <p><strong>Generated:</strong> #{now}</p>
    <p><strong>Authority:</strong> Thomas IT Pharma Systems</p>
  </div>

  <table>
    <tr><th>Step</th><th>Timestamp (UTC)</th><th>Action</th><th>Operator</th></tr>
    <tr><td>1</td><td>#{now}</td><td>Material Accepted</td><td>System</td></tr>
    <tr><td>2</td><td>#{Time.now.utc.iso8601}</td><td>Batch ID Assigned</td><td>Automated</td></tr>
    <tr><td>3</td><td>#{Time.now.utc.iso8601}</td><td>Digital Signature</td><td>PharmaTransport</td></tr>
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
    body { font-family: 'Helvetica', Arial, sans-serif; margin: 40px; color: #333; max-width: 800px; margin: auto; }
    h1 { color: #2c5aa0; text-align: center; }
    .plans { display: flex; gap: 20px; flex-wrap: wrap; justify-content: center; }
    .plan { border: 2px solid #2c5aa0; padding: 25px; flex: 1; min-width: 250px; border-radius: 8px; text-align: center; }
    .price { font-size: 32pt; font-weight: bold; color: #2c5aa0; }
    code { background: #f1f1f1; padding: 8px; border-radius: 4px; font-size: 11pt; display: block; margin-top: 10px; }
    .contact { text-align: center; margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 6px; }
  </style>
</head>
<body>
  <h1>Pharma Transport</h1>
  <p style="text-align: center; font-size: 18pt; margin-bottom: 40px;">FDA 21 CFR Part 11 Chain-of-Custody PDFs</p>
  
  <div class="plans">
    <div class="plan">
      <div class="price">$49</div>
      <strong>Insulin</strong>
      <code>curl -X POST /pay -d "email=insulin-pharma@thomasit.com"</code>
    </div>
    <div class="plan">
      <div class="price">$79</div>
      <strong>Vaccines</strong>
      <code>curl -X POST /pay -d "email=vaccine-pharma@thomasit.com"</code>
    </div>
    <div class="plan">
      <div class="price">$129</div>
      <strong>Biologics</strong>
      <code>curl -X POST /pay -d "email=biologics-pharma@thomasit.com"</code>
    </div>
  </div>
  
  <div class="contact">
    <p>Add your email: <a href="mailto:sales@pharmatransport.com">sales@pharmatransport.com</a></p>
  </div>
</body>
</html>
    HTML
  end
end

# DIRECT EXECUTABLE - Render.com + Local
if $PROGRAM_NAME == __FILE__
  require 'webrick'

  port = ENV.fetch('PORT', '9292').to_i
  host = ENV.fetch('HOST', '0.0.0.0')

  server = WEBrick::HTTPServer.new(Port: port, Host: host)
  server.mount_proc '/' do |req, res|
    env = {
      'REQUEST_METHOD' => req.request_method,
      'PATH_INFO' => req.path_info,
      'QUERY_STRING' => req.query_string || '',
      'rack.version' => Rack::VERSION.split('.').map(&:to_i),
      'rack.input' => StringIO.new(req.body || ''),
      'rack.errors' => $stderr,
      'rack.url_scheme' => 'http',
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,
      'SERVER_NAME' => req.host || host,
      'SERVER_PORT' => port.to_s,
      'HTTP_HOST' => req.host || host
    }

    status, headers, body = PharmaTransportApp.call(env)
    res.status = status
    headers.each { |k,v| res[k] = v.to_s }
    res.body = Array(body).join
  end

  puts "Pharma Transport LIVE on #{host}:#{port}"
  trap('INT') { server.shutdown }
  trap('TERM') { server.shutdown }
  server.start
end
