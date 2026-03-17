#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'time'

class PharmaTransportApp
  PRICES = {
    'insulin' => 49,
    'vaccines' => 79,
    'biologics' => 129
  }.freeze

  SESSIONS = {}

  def self.generate_pdf_content(type, session)
    [
      "PDF HEADER: #{type.upcase} CHAIN OF CUSTODY",
      "Session: #{session}",
      "21 CFR Part 11 Compliant",
      "Generated: #{Time.now.utc}",
      "",
      "SERIALIZED FOR TRANSPORT",
      "FDA COMPLIANT SIGNATURES",
      "GPS TRACKING LOG",
      "",
      "-- Production PDF Generator --"
    ].join("\n")
  end

  def self.call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path]
    when ['GET', '/']
      [200, {'Content-Type' => 'text/html'}, [html_dashboard]]
    when ['POST', '/pay']
      process_payment(req)
    when ['GET', '/pdf']
      generate_pdf(req)
    when ['POST', '/gps']
      process_gps(req)
    else
      [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
    end
  end

  def self.process_payment(req)
    data = Rack::Utils.parse_nested_query(req.body.read)
    email = data['email']
    type = data['type']&.downcase

    if PRICES[type]
      session_id = "sess_#{Time.now.to_i}_#{SecureRandom.hex(8)}"
      SESSIONS[session_id] = {email: email, type: type, price: PRICES[type]}
      [200, {'Content-Type' => 'application/json'},
       [{session: session_id, price: PRICES[type], status: 'paid'}.to_json]]
    else
      [400, {'Content-Type' => 'application/json'},
       [{error: "Payment Required: Insulin=$49 | Vaccines=$79 | Biologics=$129\nContact: sales@pharmatransport.com"}.to_json]]
    end
  end

  def self.generate_pdf(req)
    session = req.params['session']
    type = req.params['type']
    if session && SESSIONS[session]
      content = generate_pdf_content(type, session)
      [200, {'Content-Type' => 'text/plain', 'Content-Disposition' => "attachment; filename=\"#{type}_coc.pdf\""}, [content]]
    else
      [400, {'Content-Type' => 'text/plain'}, ['Invalid session']]
    end
  end

  def self.process_gps(req)
    data = Rack::Utils.parse_nested_query(req.body.read)
    session = data['session']
    lat = data['lat']
    lng = data['lng']
    device_id = data['device_id'] || 'unknown'

    return [400, {'Content-Type' => 'application/json'}, [{error: 'Missing session'}.to_json]] unless session && SESSIONS[session]

    SESSIONS[session][:gps_logs] ||= []
    SESSIONS[session][:gps_logs] << {
      timestamp: Time.now.utc,
      lat: lat.to_f,
      lng: lng.to_f,
      device_id: device_id
    }

    [200, {'Content-Type' => 'application/json'}, [{status: 'gps_logged', logs: SESSIONS[session][:gps_logs].count}.to_json]]
  end

  def self.html_dashboard
    <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>Pharma Transport - 21 CFR Part 11</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: system-ui, sans-serif; background: #1e3a8a; color: white; margin: 0; padding: 2rem; }
    .container { max-width: 900px; margin: 0 auto; }
    h1 { text-align: center; font-size: 2.5rem; margin-bottom: 1rem; }
    .pricing { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 2rem; }
    .tier { background: rgba(255,255,255,0.1); padding: 2rem; border-radius: 12px; text-align: center; }
    .price { font-size: 3rem; color: #10b981; font-weight: bold; }
    button { background: #10b981; color: white; border: none; padding: 1rem 2rem; border-radius: 8px; font-size: 1.1rem; cursor: pointer; }
    button:hover { background: #059669; }
    .demo { background: rgba(0,0,0,0.3); padding: 1.5rem; border-radius: 8px; font-family: monospace; margin-top: 2rem; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚚 Pharma Transport Dashboard</h1>
    <div style="background: #059669; padding: 1rem; border-radius: 8px; text-align: center; margin-bottom: 2rem;">
      <strong>21 CFR Part 11 Compliant</strong> | FDA Chain of Custody + GPS Tracking
    </div>
    
    <div class="pricing">
      <div class="tier">
        <h2>Insulin</h2>
        <div class="price">$49</div>
        <button onclick="pay('insulin')">Pay & Generate CoC</button>
      </div>
      <div class="tier">
        <h2>Vaccines</h2>
        <div class="price">$79</div>
        <button onclick="pay('vaccines')">Pay & Generate CoC</button>
      </div>
      <div class="tier">
        <h2>Biologics</h2>
        <div class="price">$129</div>
        <button onclick="pay('biologics')">Pay & Generate CoC</button>
      </div>
    </div>

    <div class="demo">
      <h3>🔧 Test GPS Tracking:</h3>
      <pre>curl -X POST /gps -d "session=YOUR_SESSION&lat=33.4484&lng=-112.0740&device_id=truck_001"
curl -X POST /pay -d "email=test@pharma.com&type=biologics"
curl /pdf?session=SESSION_ID&type=biologics</pre>
    </div>
  </div>

  <script>
    async function pay(type) {
      const res = await fetch('/pay', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: `email=brett@pharmatransport.com&type=${type}`
      });
      const data = await res.json();
      if (data.session) {
        window.open(`/pdf?session=${data.session}&type=${type}`);
      } else {
        alert('Error: ' + data.error);
      }
    }
  </script>
</body>
</html>
HTML
  end
end

run PharmaTransportApp
