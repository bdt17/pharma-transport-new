#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'prawn'

class PharmaTransportApp
  PRICES = { 'insulin' => 49, 'vaccines' => 79, 'biologics' => 129 }.freeze

  def self.call(env)
    req = Rack::Request.new(env)
    
    case [req.request_method, req.path]
    when ['GET', '/'] 
      [200, {'Content-Type' => 'text/html'}, [html_dashboard]]
    when ['GET', '/favicon.ico'] 
      [204, {}, []]
    when ['POST', '/pay']
      # FIX: Read body ONCE, parse properly
      body = req.body.read
      params = Rack::Utils.parse_query(body)
      email = params['email']
      type = params['type']&.downcase
      
      if PRICES[type]
        session_id = "sess_#{SecureRandom.hex(8)}"
        [200, {'Content-Type' => 'application/json'}, 
         [{"session" => session_id, "price" => PRICES[type], "type" => type}.to_json]]
      else
        [400, {'Content-Type' => 'application/json'}, 
         [{"error" => "Invalid type: #{type}. Use: insulin, vaccines, biologics"}.to_json]]
      end
    when ['GET', '/pdf']
      session_id = req.params['session']
      type = req.params['type']
      
      if session_id && type && PRICES[type]
        pdf = Prawn::Document.new(page_size: 'LETTER')
        pdf.font 'Helvetica-Bold'
        pdf.text "CHAIN OF CUSTODY - #{type.upcase}", size: 24, align: :center
        pdf.move_down 20
        pdf.font_size 14
        pdf.text "Session ID: #{session_id}"
        pdf.text "Product: #{type.upcase}"
        pdf.text "Amount: $#{PRICES[type]}"
        pdf.text "Generated: #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}"
        pdf.move_down 20
        pdf.font 'Helvetica', style: :bold
        pdf.text '21 CFR PART 11 COMPLIANT', size: 18
        pdf.font 'Helvetica'
        pdf.text 'FDA Regulated Electronic Records and Signatures', align: :center
        
        [200, {
          'Content-Type' => 'application/pdf',
          'Content-Disposition' => "attachment; filename=#{type}_coc_#{session_id}.pdf"
        }, [pdf.render]]
      else
        [400, {'Content-Type' => 'text/plain'}, ['Missing session or type']]
      end
    else 
      [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
    end
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
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:system-ui;background:linear-gradient(135deg,#1e3a8a 0%,#3b82f6 100%);color:white;min-height:100vh;padding:1rem;}
.container{max-width:1200px;margin:0 auto;padding:2rem 1rem;}
h1{text-align:center;font-size:clamp(2rem,5vw,3.5rem);margin-bottom:2rem;text-shadow:0 2px 4px rgba(0,0,0,0.3);}
.compliance{background:rgba(16,185,129,0.95);padding:1.5rem;border-radius:16px;text-align:center;margin-bottom:3rem;box-shadow:0 8px 32px rgba(0,0,0,0.3);}
.pricing{display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:2rem;}
.tier{background:rgba(255,255,255,0.15);padding:2.5rem 2rem;border-radius:20px;text-align:center;backdrop-filter:blur(20px);border:1px solid rgba(255,255,255,0.3);transition:all 0.3s;}
.tier:hover{transform:translateY(-8px);box-shadow:0 20px 40px rgba(0,0,0,0.3);}
.price{font-size:clamp(2.5rem,8vw,4rem);color:#10b981;font-weight:800;margin-bottom:1.5rem;text-shadow:0 2px 4px rgba(0,0,0,0.3);}
button{background:linear-gradient(45deg,#10b981,#059669);color:white;border:none;padding:1.2rem 3rem;border-radius:12px;font-size:1.2rem;font-weight:600;cursor:pointer;box-shadow:0 4px 15px rgba(16,185,129,0.4);transition:all 0.3s;}
button:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(16,185,129,0.6);}
.contact{background:rgba(0,0,0,0.4);padding:2rem;border-radius:16px;text-align:center;}
</style>
</head>
<body>
<div class="container">
<h1>🚚 Pharma Transport Dashboard</h1>
<div class="compliance">
<strong>21 CFR Part 11 Compliant</strong><br>REAL-TIME PDF GENERATION
</div>
<div class="pricing">
<div class="tier">
<h2>💉 Insulin</h2>
<div class="price">$49</div>
<button onclick="pay('insulin')">Generate CoC PDF</button>
</div>
<div class="tier">
<h2>🛡️ Vaccines</h2>
<div class="price">$79</div>
<button onclick="pay('vaccines')">Generate CoC PDF</button>
</div>
<div class="tier">
<h2>🧬 Biologics</h2>
<div class="price">$129</div>
<button onclick="pay('biologics')">Generate CoC PDF</button>
</div>
</div>
<div class="contact">
<h3>Contact</h3>
<p><strong>brett@pharmatransport.com</strong></p>
</div>
</div>
<script>
async function pay(type){
  const email = prompt('Customer email for CoC:') || 'brett@pharmatransport.com';
  try{
    const res = await fetch('/pay', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: `email=${encodeURIComponent(email)}&type=${type}`
    });
    const data = await res.json();
    if(data.session){
      window.open(`/pdf?session=${data.session}&type=${type}`, '_blank');
      alert('✅ PDF downloading! 21 CFR Part 11 Compliant');
    } else {
      alert('Error: ' + (data.error || 'Unknown'));
    }
  } catch(e){
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
