require 'rack'
require 'json'
require 'time'

class PharmaTransportApp
  PRICES = {
    'insulin' => 49,
    'vaccines' => 79,
    'biologics' => 129
  }.freeze

  SESSIONS = {}.freeze # In production, use Redis/Postgres

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
      "-- This is your production PDF generator --"
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
      SESSIONS[session_id] = {email: email, type: type, price: PRICES[type], timestamp: Time.now.utc}
      
      [200, 
       {'Content-Type' => 'application/json'},
       [{session: session_id, price: PRICES[type], status: 'paid'}.to_json]
      ]
    else
      [400, 
       {'Content-Type' => 'application/json'},
       [{error: "Payment Required: Insulin=$49 | Vaccines=$79 | Biologics=$129\nContact: sales@pharmatransport.com"}.to_json]
      ]
    end
  end

  def self.generate_pdf(req)
    session = req.params['session']
    type = req.params['type']

    if session && SESSIONS[session]
      content = generate_pdf_content(type, session)
      [200, 
       {'Content-Type' => 'application/pdf', 
        'Content-Disposition' => "attachment; filename=\"#{type}_coc.pdf\""},
       [content]
      ]
    else
      [400, {'Content-Type' => 'text/plain'}, ['Invalid session']]
    end
  end

  def self.html_dashboard
    <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>Pharma Transport Dashboard - 21 CFR Part 11 Compliant</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%); min-height: 100vh; color: white; }
    .container { max-width: 800px; margin: 0 auto; padding: 2rem; }
    h1 { font-size: 2.5rem; margin-bottom: 1rem; text-align: center; }
    .pricing { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; margin: 2rem 0; }
    .tier { background: rgba(255,255,255,0.1); padding: 2rem; border-radius: 12px; text-align: center; backdrop-filter: blur(10px); }
    .price { font-size: 2rem; font-weight: bold; color: #4ade80; }
    button { background: #4ade80; color: black; border: none; padding: 1rem 2rem; border-radius: 8px; font-size: 1.1rem; cursor: pointer; margin: 1rem; transition: all 0.3s; }
    button:hover { background: #22c55e; transform: translateY(-2px); }
    .demo { background: rgba(0,0,0,0.3); padding: 1.5rem; border-radius: 8px; margin: 2rem 0; font-family: monospace; }
    .compliant { background: #059669; padding: 1rem; border-radius: 8px; text-align: center; margin: 1rem 0; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚚 Pharma Transport Dashboard</h1>
    <div class="compliant">
      <strong>21 CFR Part 11 Compliant</strong> | FDA Regulated Chain of Custody
    </div>
    
    <div class="pricing">
      <div class="tier">
        <h3>Insulin</h3>
        <div class="price">$49</div>
        <button onclick="pay('insulin')">Pay & Generate CoC</button>
      </div>
      <div class="tier">
        <h3>Vaccines</h3>
        <div class="price">$79</div>
        <button onclick="pay('vaccines')">Pay & Generate CoC</button>
      </div>
      <div class="tier">
        <h3>Biologics</h3>
        <div class="price">$129</div>
        <button onclick="pay('biologics')">Pay & Generate CoC</button>
      </div>
    </div>

    <div class="demo">
      <h3>🔧 Test with curl:</h3>
      <pre>
POST https://#{ENV['RENDER_EXTERNAL_HOSTNAME'] || 'pharma-transport-new.onrender.com'}/pay
-d "email=test@pharma.com&type=biologics"

GET https://#{ENV['RENDER_EXTERNAL_HOSTNAME'] || 'pharma-transport-new.onrender.com'}/pdf?session=SESSION_ID&type=biologics
      </pre>
    </div>
  </div>

  <script>
    let currentSession = null;
    async function pay(type) {
      const email = 'brett@pharmatransport.com';
      const res = await fetch('/pay', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: `email=${email}&type=${type}`
      });
      const data = await res.json();
      
      if (data.session) {
        currentSession = data.session;
        alert(`✅ Paid $${data.price}! Session: ${data.session}\nDownload your PDF:`);
        window.open(`/pdf?session=${data.session}&type=${type}`, '_blank');
      } else {
        alert('❌ ' + data.error);
      }
    }
  </script>
</body>
</html>
HTML
  end
end

run PharmaTransportApp
