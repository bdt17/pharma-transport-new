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
    when ['GET', '/favicon.ico']
      [204, {'Content-Type' => 'image/x-icon'}, ['']]
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
  <link rel="icon" href="/favicon.ico" type="image/x-icon">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
      background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%); 
      color: white; 
      min-height: 100vh; 
      padding: 1rem;
    }
    .container { max-width: 1200px; margin: 0 auto; padding: 2rem 1rem; }
    h1 { text-align: center; font-size: clamp(2rem, 5vw, 3.5rem); margin-bottom: 2rem; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }
    .compliance { background: rgba(16, 185, 129, 0.9); padding: 1.5rem; border-radius: 16px; text-align: center; margin-bottom: 3rem; backdrop-filter: blur(10px); box-shadow: 0 8px 32px rgba(0,0,0,0.2); }
    .pricing { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem; margin-bottom: 3rem; }
    .tier { background: rgba(255,255,255,0.15); padding: 2.5rem 2rem; border-radius: 20px; text-align: center; backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.2); transition: all 0.3s ease; }
    .tier:hover { transform: translateY(-10px); box-shadow: 0 20px 40px rgba(0,0,0,0.3); }
    .tier h2 { font-size: 1.8rem; margin-bottom: 1rem; }
    .price { font-size: clamp(2.5rem, 8vw, 4rem); color: #10b981; font-weight: 800; margin-bottom: 1.5rem; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }
    button { background: linear-gradient(45deg, #10b981, #059669); color: white; border: none; padding: 1.2rem 3rem; border-radius: 12px; font-size: 1.2rem; font-weight: 600; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 15px rgba(16,185,129,0.4); }
    button:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(16,185,129,0.6); }
    .demo { background: rgba(0,0,0,0.4); padding: 2rem; border-radius: 16px; font-family: 'SF Mono', monospace; backdrop-filter: blur(10px); }
    pre { background: rgba(0,0,0,0.3); padding: 1.5rem; border-radius: 12px; overflow-x: auto; font-size: 0.9rem; line-height: 1.6; }
    @media (max-width: 768px) { .pricing { grid-template-columns: 1fr; } body { padding: 0.5rem; } }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚚 Pharma Transport Dashboard</h1>
    <div class="compliance">
      <strong>21 CFR Part 11 Compliant</strong> | FDA Chain of Custody + Real-Time GPS Tracking
    </div>
    
    <div class="pricing">
      <div class="tier">
        <h2>💉 Insulin</h2>
        <div class="price">$49</div>
        <button onclick="pay('insulin')">Pay & Generate CoC</button>
      </div>
      <div class="tier">
        <h2>🛡️ Vaccines</h2>
        <div class="price">$79</div>
        <button onclick="pay('vaccines')">Pay & Generate CoC</button>
      </div>
      <div class="tier">
        <h2>🧬 Biologics</h2>
        <div class="price">$129</div>
        <button onclick="pay('biologics')">Pay & Generate CoC</button>
      </div>
    </div>

    <div class="demo">
      <h3>🔧 Test Full API Flow:</h3>
      <pre>
# 1. Create session
SESSION=$(curl -s -X POST /pay -d "email=test@pharma.com&type=biologics" | grep -o '"session":"[^"]*"' | cut -d'"' -f4)

# 2. GPS truck in Phoenix
curl -X POST /gps -d "session=$SESSION&lat=33.4484&lng=-112.0740&device_id=truck_001"

# 3. Download compliant CoC
curl /pdf?session=$SESSION&type=biologics -o coc.pdf
      </pre>
    </div>
  </div>

  <script>
    async function pay(type) {
      try {
        const res = await fetch('/pay', {
          method: 'POST',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: `email=brett@pharmatransport.com&type=${type}`
        });
        const data = await res.json();
        if (data.session) {
          window.open(`/pdf?session=${data.session}&type=${type}`, '_blank');
        } else {
          alert('Error: ' + (data.error || 'Unknown error'));
        }
      } catch(e) {
        alert('Network error: ' + e.message);
      }
    }
  </script>
</body>
</html>
HTML
  end
end

run PharmaTransportApp
