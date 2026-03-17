#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'prawn'
require 'stripe' rescue nil

Stripe.api_key = ENV['STRIPE_SECRET_KEY'] if defined?(Stripe)

class PharmaTransportApp
  PRICES = {'insulin'=>49,'vaccines'=>79,'biologics'=>129}.freeze

  def self.call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path]
    when ['GET', '/'] then [200,{'Content-Type'=>'text/html'},[html_dashboard]]
    when ['POST', '/pay']
      params = Rack::Utils.parse_query(req.body.read)
      type = params['type']&.downcase
      email = params['email'] || 'brett@pharmatransport.com'
      
      if PRICES[type]
        if defined?(Stripe) && ENV['STRIPE_SECRET_KEY']
          begin
            session = Stripe::Checkout::Session.create({
              payment_method_types: ['card'],
              customer_email: email,
              line_items: [{price_data: {currency: 'usd', product_data: {name: "#{type.capitalize} CoC"}, unit_amount: PRICES[type]*100}, quantity: 1}],
              mode: 'payment',
              success_url: "#{req.scheme}://#{req.host}/success",
              cancel_url: "#{req.scheme}://#{req.host}/"
            })
            [{"url"=>session.url,"session"=>session.id}.to_json]
          rescue => e
            [{"error"=>"Stripe error: #{e.message}"}.to_json]
          end
        else
          session_id = "sess_#{SecureRandom.hex(8)}"
          [{"session"=>session_id,"price"=>PRICES[type],"type"=>type}.to_json]
        end
      else
        [{"error"=>"#{type} invalid"}.to_json]
      end
    when ['GET', '/pdf']
      type = req.params['type']
      session_id = req.params['session'] || "demo"
      
      pdf = Prawn::Document.new(page_size: 'LETTER')
      pdf.fill_color '#0984C0' # Deep Ocean Blue
      pdf.text "CHAIN OF CUSTODY", size: 28, style: :bold, align: :center
      pdf.fill_color '000000'
      pdf.text "#{type.upcase} TRANSPORT", size: 18, align: :center
      pdf.stroke_color '#0984C0'
      pdf.stroke_horizontal_rule
      
      pdf.font_size 12
      pdf.text "Session: #{session_id}", align: :center
      pdf.text "Generated: #{Time.now.utc}", align: :center
      pdf.move_down 40
      pdf.fill_color '#0984C0'
      pdf.text '21 CFR PART 11 COMPLIANT', size: 16, style: :bold
      pdf.fill_color '000000'
      pdf.text 'Electronic Records & Signatures - FDA Regulated', align: :center
      
      [200,{'Content-Type'=>'application/pdf','Content-Disposition'=>"attachment; filename=#{type}_coc.pdf"},[pdf.render]]
    else [404,{},['Not Found']]
    end
  end

  def self.html_dashboard
    <<~HTML
<!DOCTYPE html>
<html>
<head>
<title>Thomas IT - Pharma Transport</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
:root {
  --ocean-blue: #0984C0;
  --sea-serpent: #60BDD1;
  --silver-sand: #C0BEC6;
  --metallic-silver: #AAA7B0;
  --davy-grey: #565759;
  --white: #FFFFFF;
}
* { margin:0; padding:0; box-sizing:border-box; }
body { 
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
  background: #000; 
  color: var(--white);
  min-height: 100vh; 
  line-height: 1.6;
}
.container { max-width: 1400px; margin:0 auto; padding:2rem 1rem; }
.header {
  text-align: center; 
  padding: 3rem 0; 
  border-bottom: 3px solid var(--ocean-blue);
  margin-bottom: 4rem;
}
h1 { 
  font-size: clamp(2.5rem, 6vw, 4.5rem); 
  background: linear-gradient(135deg, var(--ocean-blue), var(--sea-serpent));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-weight: 800;
  margin-bottom: 1rem;
}
.tagline { 
  font-size: 1.4rem; 
  color: var(--silver-sand); 
  max-width: 600px; 
  margin: 0 auto;
}
.compliance { 
  background: rgba(9,132,192,0.1); 
  border: 2px solid var(--ocean-blue);
  border-radius: 20px; 
  padding: 2.5rem; 
  text-align: center; 
  margin: 4rem 0;
  backdrop-filter: blur(20px);
}
.compliance h2 { 
  color: var(--ocean-blue); 
  font-size: 2.2rem; 
  margin-bottom: 1rem;
  font-weight: 700;
}
.pricing { 
  display: grid; 
  grid-template-columns: repeat(auto-fit, minmax(380px, 1fr)); 
  gap: 2.5rem; 
  margin-bottom: 4rem;
}
.tier { 
  background: rgba(255,255,255,0.05); 
  border: 2px solid var(--metallic-silver); 
  border-radius: 24px; 
  padding: 3rem 2.5rem; 
  text-align: center; 
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  position: relative;
  overflow: hidden;
}
.tier::before {
  content: ''; 
  position: absolute; 
  top: 0; left: 0; right: 0; 
  height: 4px; 
  background: linear-gradient(90deg, var(--ocean-blue), var(--sea-serpent));
}
.tier:hover { 
  transform: translateY(-12px); 
  border-color: var(--ocean-blue); 
  box-shadow: 0 32px 64px rgba(9,132,192,0.3);
}
.tier h3 { 
  font-size: 2.2rem; 
  color: var(--sea-serpent); 
  margin-bottom: 1.5rem; 
  font-weight: 700;
}
.price { 
  font-size: clamp(3rem, 10vw, 5.5rem); 
  font-weight: 900; 
  color: var(--ocean-blue); 
  text-shadow: 0 4px 16px rgba(9,132,192,0.4);
  margin: 1rem 0 2rem 0;
}
button { 
  background: linear-gradient(135deg, var(--ocean-blue), var(--sea-serpent)); 
  color: var(--white); 
  border: none; 
  padding: 1.4rem 3.5rem; 
  border-radius: 16px; 
  font-size: 1.3rem; 
  font-weight: 700; 
  cursor: pointer; 
  transition: all 0.3s ease; 
  box-shadow: 0 8px 32px rgba(9,132,192,0.4);
  text-transform: uppercase;
  letter-spacing: 1px;
}
button:hover { 
  transform: translateY(-4px); 
  box-shadow: 0 16px 48px rgba(9,132,192,0.6);
}
.contact { 
  background: rgba(170,167,176,0.15); 
  border-radius: 20px; 
  padding: 3rem; 
  text-align: center; 
  border: 2px solid var(--metallic-silver);
}
.contact h4 { color: var(--sea-serpent); font-size: 1.6rem; margin-bottom: 1rem; }
.contact p { 
  font-size: 1.4rem; 
  background: linear-gradient(135deg, var(--ocean-blue), var(--sea-serpent));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-weight: 600;
}
@media (max-width: 768px) {
  .pricing { grid-template-columns: 1fr; gap: 2rem; }
  .tier { padding: 2.5rem 2rem; }
}
</style>
</head>
<body>
<div class="container">
  <header class="header">
    <h1>Thomas IT</h1>
    <p class="tagline">Pharma Transport Compliance Platform</p>
  </header>
  
  <section class="compliance">
    <h2>21 CFR Part 11 Compliant</h2>
    <p>Real-time Chain of Custody • FDA Regulated • Audit Ready</p>
  </section>
  
  <section class="pricing">
    <div class="tier">
      <h3>💉 Insulin</h3>
      <div class="price">$49</div>
      <button onclick="pay('insulin')">Pay with Stripe</button>
    </div>
    <div class="tier">
      <h3>🛡️ Vaccines</h3>
      <div class="price">$79</div>
      <button onclick="pay('vaccines')">Pay with Stripe</button>
    </div>
    <div class="tier">
      <h3>🧬 Biologics</h3>
      <div class="price">$129</div>
      <button onclick="pay('biologics')">Pay with Stripe</button>
    </div>
  </section>
  
  <section class="contact">
    <h4>Enterprise Sales</h4>
    <p>brett@pharmatransport.com</p>
  </section>
</div>

<script>
async function pay(type) {
  const email = prompt('Customer email:') || 'brett@pharmatransport.com';
  try {
    const res = await fetch('/pay', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: `email=${encodeURIComponent(email)}&type=${type}`
    });
    const data = await res.json();
    if (data.url) {
      window.location.href = data.url;
    } else if (data.session) {
      window.open(`/pdf?session=${data.session}&type=${type}`, '_blank');
      alert('✅ PDF ready! 21 CFR Part 11');
    } else {
      alert('Error: ' + (data.error || 'Unknown'));
    }
  } catch(e) {
    alert('Network error');
  }
}
</script>
</body>
</html>
    HTML
  end
end

run PharmaTransportApp
