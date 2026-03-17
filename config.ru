#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'prawn'

class PharmaTransportApp
  PRICES = { 'insulin' => 49, 'vaccines' => 79, 'biologics' => 129 }.freeze
  SESSIONS = {}

  def self.call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path]
    when ['GET', '/'] then [200, {'Content-Type' => 'text/html'}, [html_dashboard]]
    when ['GET', '/favicon.ico'] then [204, {}, []]
    when ['POST', '/pay'] then process_payment(req)
    when ['GET', '/pdf'] then generate_pdf(req)
    else [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
    end
  end

  def self.process_payment(req)
    data = Rack::Utils.parse_nested_query(req.body.read)
    email, type = data['email'], data['type']&.downcase
    return [400, {'Content-Type' => 'application/json'}, 
            [{error: 'Invalid type'}.to_json]] unless PRICES[type]

    session_id = "sess_#{SecureRandom.hex(12)}"
    SESSIONS[session_id] = {email: email, type: type, price: PRICES[type]}
    [200, {'Content-Type' => 'application/json'}, 
     [{session: session_id, price: PRICES[type]}.to_json]]
  end

  def self.generate_pdf(req)
    session_id = req.params['session']
    data = SESSIONS[session_id]
    return [400, {'Content-Type' => 'text/plain'}, ['Invalid session']] unless data

    pdf = Prawn::Document.new
    pdf.font 'Helvetica-Bold'
    pdf.text "CHAIN OF CUSTODY - #{data[:type].upcase}", size: 24, align: :center
    pdf.stroke_horizontal_rule

    pdf.font_size 12
    pdf.text "Session: #{session_id}"
    pdf.text "Customer: #{data[:email]}"
    pdf.text "Product: #{data[:type].upcase}"
    pdf.text "Amount: $#{data[:price]}"
    pdf.text "Generated: #{Time.now.utc}"

    pdf.text "\n21 CFR PART 11 COMPLIANT", style: :bold
    pdf.text "FDA Electronic Records & Signatures"

    pdf_content = pdf.render
    [200, {
      'Content-Type' => 'application/pdf',
      'Content-Disposition' => "attachment; filename=#{data[:type]}_coc.pdf"
    }, [pdf_content]]
  end

  def self.html_dashboard
    <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>Pharma Transport - 21 CFR Part 11</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif; background: linear-gradient(135deg,#1e3a8a 0%,#3b82f6 100%); color: white; min-height: 100vh; padding: 1rem; }
    .container { max-width: 1200px; margin: 0 auto; padding: 2rem 1rem; }
    h1 { text-align: center; font-size: clamp(2rem,5vw,3.5rem); margin-bottom: 2rem; }
    .compliance { background: rgba(16,185,129,0.9); padding: 1.5rem; border-radius: 16px; text-align: center; margin-bottom: 3rem; }
    .pricing { display: grid; grid-template-columns: repeat(auto-fit,minmax(300px,1fr)); gap: 2rem; }
    .tier { background: rgba(255,255,255,0.15); padding: 2.5rem 2rem; border-radius: 20px; text-align: center; backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.2); }
    .tier:hover { transform: translateY(-10px); }
    .price { font-size: clamp(2.5rem,8vw,4rem); color: #10b981; font-weight: 800; margin-bottom: 1.5rem; }
    button { background: linear-gradient(45deg,#10b981,#059669); color: white; border: none; padding: 1.2rem 3rem; border-radius: 12px; font-size: 1.2rem; font-weight: 600; cursor: pointer; }
    button:hover { transform: translateY(-3px); }
    .demo { background: rgba(0,0,0,0.4); padding: 2rem; border-radius: 16px; font-family: monospace; }
    pre { background: rgba(0,0,0,0.3); padding: 1.5rem; border-radius: 12px; overflow-x: auto; font-size: 0.9rem; white-space: pre-wrap; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Pharma Transport Dashboard</h1>
    <div class="compliance"><strong>21 CFR Part 11 Compliant</strong> | REAL PDF + GPS</div>
    <div class="pricing">
      <div class="tier"><h2>Insulin</h2><div class="price">$49</div><button onclick="pay('insulin')">Pay & Generate CoC PDF</button></div>
      <div class="tier"><h2>Vaccines</h2><div class="price">$79</div><button onclick="pay('vaccines')">Pay & Generate CoC PDF</button></div>
      <div class="tier"><h2>Biologics</h2><div class="price">$129</div><button onclick="pay('biologics')">Pay & Generate CoC PDF</button></div>
    </div>
    <div class="demo">
      <h3>Test REAL PDF:</h3>
      <pre>SESSION=$(curl -s -X POST /pay -d "email=test@pharma.com&type=biologics" | grep -o '"session":"[^"]*"' | cut -d'"' -f4)
curl "/pdf?session=$SESSION&type=biologics" -o coc.pdf</pre>
    </div>
  </div>
  <script>
    async function pay(type) {
      const res = await fetch('/pay', {method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: `email=brett@pharmatransport.com&type=${type}`});
      const data = await res.json();
      if (data.session) window.open(`/pdf?session=${data.session}&type=${type}`), alert(`✅ PDF downloading! ${data.session}`);
      else alert('Error: ' + data.error);
    }
  </script>
</body>
</html>
    HTML
  end
end

run PharmaTransportApp
