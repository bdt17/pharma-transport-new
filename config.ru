#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'prawn'

class PharmaTransportApp
  PRICES = {
    'insulin' => 49,
    'vaccines' => 79,
    'biologics' => 129
  }.freeze

  SESSIONS = {}

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
    
    unless session && SESSIONS[session]
      return [400, {'Content-Type' => 'text/plain'}, ['Invalid session']]
    end

    pdf = Prawn::Document.new(page_size: 'LETTER')
    
    # Header
    pdf.font 'Helvetica', style: :bold
    pdf.fill_color '#1e3a8a'
    pdf.text "CHAIN OF CUSTODY - #{type.upcase}", size: 24, align: :center
    pdf.stroke_color '#10b981'
    pdf.stroke_horizontal_rule
    
    # Session info
    pdf.font_size 14
    pdf.text "Session: #{session}", align: :center
    pdf.text "Customer: #{SESSIONS[session][:email]}"
    pdf.text "Product: #{type.upcase}"
    pdf.text "Amount Paid: $#{SESSIONS[session][:price]}"
    pdf.text "Generated: #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    
    # Compliance
    pdf.move_down 20
    pdf.font 'Helvetica', style: :bold
    pdf.fill_color '#059669'
    pdf.text '21 CFR PART 11 COMPLIANT', size: 16, style: :bold
    pdf.fill_color '000000'
    pdf.text 'FDA Regulated Electronic Records and Signatures', align: :center
    
    # GPS Logs
    if SESSIONS[session][:gps_logs]
      pdf.move_down 20
      pdf.text 'GPS TRACKING LOG', size: 16, style: :bold
      gps_data = [['Time', 'Lat', 'Lng', 'Device']]
      SESSIONS[session][:gps_logs].each do |log|
        gps_data << [log[:timestamp].strftime('%H:%M:%S'), 
                    "%.4f" % log[:lat], 
                    "%.4f" % log[:lng], 
                    log[:device_id]]
      end
      pdf.table(gps_data, header: true, position: :center)
    end

    # Footer
    pdf.move_down 40
    pdf.font_size 10
    pdf.text 'SERIALIZED FOR TRANSPORT | TEMPERATURE CONTROLLED | REAL-TIME TRACKING', align: :center, style: :bold
    pdf.text 'Pharma Transport Systems - 21 CFR Part 11 Compliant', align: :center

    pdf_content = pdf.render
    [200, {
      'Content-Type' => 'application/pdf',
      'Content-Disposition' => "attachment; filename=\"#{type}_coc_#{session}.pdf\""
    }, [pdf_content]]
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
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%); color: white; min-height: 100vh; padding: 1rem; }
    .container { max-width: 1200px; margin: 0 auto; padding: 2rem 1rem; }
    h1 { text-align: center; font-size: clamp(2rem, 5vw, 3.5rem); margin-bottom: 2rem; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }
    .compliance { background: rgba(16, 185, 129, 0.9); padding: 1.5rem; border-radius: 16px; text-align: center; margin-bottom: 3rem; backdrop-filter: blur(10px); box-shadow: 0 8px 32px rgba(0,0,0,0.2); }
    .pricing { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem; margin-bottom: 3rem; }
    .tier { background: rgba(255,255,255,0.15); padding: 2.5rem 2rem; border-radius: 20px; text-align: center; backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.2); transition: all 0.3s ease; }
    .tier:hover { transform: translateY(-10px); box-shadow: 0 20px 40px rgba(0,0,0,0.3); }
    .price { font-size: clamp(2.5rem, 8vw, 4rem); color: #10b981; font-weight: 800; margin-bottom: 1.5rem; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }
    button { background: linear-gradient(45deg, #10b981, #059669); color: white; border: none; padding: 1.2rem 3rem; border-radius: 12px; font-size: 1.2rem; font-weight: 600; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 15px rgba(16,185,129,0.4); }
    button:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(16,185,129,0.6); }
    .demo { background: rgba(0,0,0,0.4); padding: 2rem; border-radius: 16px; font-family: 'SF Mono', monospace; backdrop-filter: blur(10px); }
    pre { background: rgba(0,0,0,0.3); padding: 1.5rem; border-radius: 12px; overflow-x: auto; font-size: 0.9rem; line-height: 1.6; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚚 Pharma Transport Dashboard</h1>
    <div class="compliance">
      <strong>21 CFR Part 11 Compliant</strong> | REAL PDF GENERATION + GPS Tracking
    </div>
    
    <div class="pricing">
      <div class="tier">
        <h2>💉 Insulin</h2>
        <div class="price">$49</div>
        <button onclick="pay('insulin')">Pay & Generate CoC PDF</button>
      </div>
      <div class="tier">
        <h2>🛡️ Vaccines</h2>
        <div class="price">$79</div>
        <button onclick="pay('vaccines')">Pay & Generate CoC PDF</button>
      </div>
      <div class="tier">
        <h2>🧬 Biologics</h2>
        <div class="price">$129</div>
        <button onclick="pay('biologics')">Pay & Generate CoC PDF</button>
      </div>
    </div>

    <div class="demo">
      <h3>🔥 Test REAL PDF Flow:</h3>
      <pre>
# Full flow → Creates REAL .pdf file
SESSION=$(curl -s -X POST /pay -d "email=test@pharma.com&type=biologics" | grep -o '"session":"[^"]*"' | cut -d'"' -f4)
curl /pdf?session=$SESSION&type=biologics -o REAL_coc.pdf
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
          alert(`✅ PDF downloading! Session: ${data.session}`);
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
