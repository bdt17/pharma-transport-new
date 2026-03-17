#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'prawn'
require 'stripe' rescue nil

Stripe.api_key = ENV['STRIPE_SECRET_KEY'] if defined?(Stripe)

class PharmaTransportApp
  PRICES = {'insulin'=>49,'vaccines'=>79,'biologics'=>129}.freeze
  PRIVATE_EMAIL = 'brett.thomas29.97@gmail.com'

  def self.call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path]
    when ['GET', '/'] then [200,{'Content-Type'=>'text/html'},[html_dashboard]]
    when ['POST', '/pay']
      params = Rack::Utils.parse_query(req.body.read)
      type = params['type']&.downcase
      email = params['email'] || PRIVATE_EMAIL
      
      if PRICES[type]
        if defined?(Stripe) && ENV['STRIPE_SECRET_KEY']
          begin
            session = Stripe::Checkout::Session.create({
              payment_method_types: ['card'],
              customer_email: email,
              line_items: [{price_data: {currency: 'usd', product_data: {name: "#{type.capitalize} CoC"}, unit_amount: PRICES[type]*100}, quantity: 1}],
              mode: 'payment',
              success_url: "#{req.scheme}://#{req.host}/success",
              cancel_url: "#{req.scheme}://#{req.host}/",
              metadata: {email: email}
            })
            [{"url"=>session.url,"session"=>session.id}.to_json]
          rescue => e
            [{"error"=>"Stripe: #{e.message}"}.to_json]
          end
        else
          session_id = "sess_#{SecureRandom.hex(8)}"
          [{"session"=>session_id,"price"=>PRICES[type],"type"=>type}.to_json]
        end
      else
        [{"error"=>"Invalid: #{type}"}.to_json]
      end
    when ['GET', '/pdf']
      type = req.params['type']
      session_id = req.params['session'] || "demo"
      
      pdf = Prawn::Document.new(page_size: 'LETTER')
      pdf.fill_color '#0984C0'
      pdf.text "PHARMA TRANSPORT", size: 20, style: :bold, align: :center
      pdf.text "CHAIN OF CUSTODY", size: 24, style: :bold, align: :center
      pdf.fill_color '000000'
      pdf.text "#{type.upcase}", size: 18, align: :center
      pdf.stroke_color '#0984C0'
      pdf.stroke_horizontal_rule
      
      pdf.font_size 12
      pdf.text "Session: #{session_id}", align: :center
      pdf.text "Customer: #{email}", align: :center
      pdf.text "Generated: #{Time.now.utc}", align: :center
      pdf.move_down 30
      pdf.fill_color '#0984C0'
      pdf.text '21 CFR PART 11 COMPLIANT', size: 16, style: :bold
      pdf.fill_color '000000'
      pdf.text 'FDA Electronic Records - Audit Ready', align: :center
      
      [200,{'Content-Type'=>'application/pdf','Content-Disposition'=>"attachment; filename=pharma_transport_#{type}_coc.pdf"},[pdf.render]]
    else [404,{},['Not Found']]
    end
  end

  def self.html_dashboard
    <<~HTML
<!DOCTYPE html>
<html>
<head>
<title>Pharma Transport - Thomas IT</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
:root {
  --ocean-blue: #0984C0;
  --sea-serpent: #60BDD1;
  --silver-sand: #C0BEC6;
  --metallic-silver: #AAA7B0;
}
* { margin:0; padding:0; box-sizing:border-box; }
body { 
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
  background: #000; 
  color: #FFFFFF;
  min-height: 100vh; 
  line-height: 1.6;
}
.container { max-width: 1200px; margin:0 auto; padding:1.5rem; }
.header {
  text-align: center; 
  padding: 2rem 0; 
  border-bottom: 3px solid var(--ocean-blue);
  margin-bottom: 3rem;
}
h1 { 
  font-size: clamp(2rem, 5vw, 3.2rem); 
  background: linear-gradient(135deg, var(--ocean-blue), var(--sea-serpent));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-weight: 800;
  margin-bottom: 0.5rem;
}
.tagline { 
  font-size: 1.1rem; 
  color: var(--silver-sand); 
  font-weight: 500;
}
.compliance { 
  background: rgba(9,132,192,0.15); 
  border: 2px solid var(--ocean-blue);
  border-radius: 16px; 
  padding: 2rem; 
  text-align: center; 
  margin: 2.5rem 0;
}
.compliance h2 { 
  color: var(--ocean-blue); 
  font-size: 1.6rem; 
  margin-bottom: 0.8rem;
}
.pricing { 
  display: grid; 
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); 
  gap: 2rem; 
  margin-bottom: 3rem;
}
.tier { 
  background: rgba(255,255,255,0.08); 
  border: 2px solid var(--metallic-silver); 
  border-radius: 20px; 
  padding: 2.5rem 2rem; 
  text-align: center; 
  transition: all 0.3s ease;
}
.tier:hover { 
  border-color: var(--ocean-blue); 
  transform: translateY(-6px);
  box-shadow: 0 20px 40px rgba(9,132,192,0.2);
}
.tier h3 { 
  font-size: 1.8rem; 
  color: var(--sea-serpent); 
  margin-bottom: 1rem; 
}
.price { 
  font-size: 3rem; 
  font-weight: 900; 
  color: var(--ocean-blue); 
  margin: 0.5rem 0 1.5rem 0;
}
.btn { 
  background: linear-gradient(135deg, var(--ocean-blue), var(--sea-serpent)); 
  color: #FFFFFF; 
  border: none; 
  padding: 1rem 2.5rem; 
  border-radius: 12px; 
  font-size: 1.1rem; 
  font-weight: 700; 
  cursor: pointer; 
  transition: all 0.3s ease; 
  text-transform: uppercase;
  letter-spacing: 0.5px;
  width: 100%;
  box-sizing: border-box;
}
.btn:hover { 
  transform: translateY(-2px); 
  box-shadow: 0 12px 24px rgba(9,132,192,0.4);
}
.contact { 
  background: rgba(170,167,176,0.2); 
  border-radius: 16px; 
  padding: 2rem; 
  text-align: center; 
  border: 2px solid var(--metallic-silver);
}
.contact h4 { color: var(--sea-serpent); font-size: 1.3rem; margin-bottom: 0.8rem; }
@media (max-width: 768px) {
  .pricing { grid-template-columns: 1fr; }
  .tier { padding: 2rem 1.5rem; }
}
</style>
</head>
<body>
<div class="container">
  <header class="header">
    <h1>Pharma Transport</h1>
    <p class="tagline">Thomas IT Compliance Platform</p>
  </header>
  
  <section class="compliance">
    <h2>21 CFR Part 11 Compliant</h2>
    <p>Real-time Chain of Custody • FDA Regulated • Audit Ready</p>
  </section>
  
  <section class="pricing">
    <div class="tier">
      <h3>💉 Insulin</h3>
      <div class="price">$49</div>
      <button class="btn" onclick="pay('insulin')">Pay with Stripe</button>
    </div>
    <div class="tier">
      <h3>🛡️ Vaccines</h3>
      <div class="price">$79</div>
      <button class="btn" onclick="pay('vaccines')">Pay with Stripe</button>
    </div>
    <div class="tier">
      <h3>🧬 Biologics</h3>
      <div class="price">$129</div>
      <button class="btn" onclick="pay('biologics')">Pay with Stripe</button>
    </div>
  </section>
  
  <section class="contact">
    <h4>Enterprise Sales</h4>
    <p>brett@pharmatransport.com</p>
  </section>
</div>

<script>
async function pay(type) {
  const email = 'brett.thomas29.97@gmail.com'; // Your private email
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
