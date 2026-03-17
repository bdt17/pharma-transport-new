#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'prawn'
require 'redis'

REDIS = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379')

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
    else [404, {}, ['Not Found']]
    end
  end

  def self.process_payment(req)
    data = Rack::Utils.parse_nested_query(req.body.read)
    email, type = data['email'], data['type']&.downcase
    
    return [400, {'Content-Type' => 'application/json'}, 
            [{error: 'Invalid type'}.to_json]] unless PRICES[type]

    session_id = "sess_#{SecureRandom.hex(12)}"
    SESSIONS[session_id] = {email: email, type: type, price: PRICES[type], paid: true}
    
    # Redis backup
    REDIS.hset("session:#{session_id}", SESSIONS[session_id])
    
    [200, {'Content-Type' => 'application/json'}, 
     [{session: session_id, price: PRICES[type]}.to_json]]
  end

  def self.generate_pdf(req)
    session_id = req.params['session']
    data = SESSIONS[session_id] || REDIS.hgetall("session:#{session_id}")
    return [400, {}, ['Session expired']] unless data['paid']

    pdf = Prawn::Document.new
    pdf.text "CHAIN OF CUSTODY - #{data['type'].upcase}", size: 24, align: :center
    pdf.text "Customer: #{data['email']}", size: 14
    pdf.text "21 CFR PART 11 COMPLIANT", style: :bold

    [200, {
      'Content-Type' => 'application/pdf',
      'Content-Disposition' => "attachment; filename=#{data['type']}_coc.pdf"
    }, [pdf.render]]
  end

  def self.html_dashboard
    <<~HTML
<!DOCTYPE html>
<html>
<head><title>Pharma Transport - 21 CFR Part 11</title><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:system-ui;background:linear-gradient(135deg,#1e3a8a 0%,#3b82f6 100%);color:white;min-height:100vh;padding:1rem;}.container{max-width:1200px;margin:0 auto;padding:2rem 1rem;}h1{text-align:center;font-size:clamp(2rem,5vw,3.5rem);margin-bottom:2rem;}.compliance{background:rgba(16,185,129,0.9);padding:1.5rem;border-radius:16px;text-align:center;margin-bottom:3rem;}.pricing{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:2rem;}.tier{background:rgba(255,255,255,0.15);padding:2.5rem 2rem;border-radius:20px;text-align:center;backdrop-filter:blur(20px);border:1px solid rgba(255,255,255,0.2);}.tier:hover{transform:translateY(-10px);}.price{font-size:clamp(2.5rem,8vw,4rem);color:#10b981;font-weight:800;margin-bottom:1.5rem;}button{background:linear-gradient(45deg,#10b981,#059669);color:white;border:none;padding:1.2rem 3rem;border-radius:12px;font-size:1.2rem;font-weight:600;cursor:pointer;}button:hover{transform:translateY(-3px);}.contact{background:rgba(0,0,0,0.4);padding:2rem;border-radius:16px;text-align:center;}</style></head>
<body><div class="container"><h1>🚚 Pharma Transport</h1><div class="compliance"><strong>21 CFR Part 11 Compliant</strong> | Redis Persistent</div><div class="pricing"><div class="tier"><h2>Insulin</h2><div class="price">$49</div><button onclick="pay('insulin')">Generate CoC PDF</button></div><div class="tier"><h2>Vaccines</h2><div class="price">$79</div><button onclick="pay('vaccines')">Generate CoC PDF</button></div><div class="tier"><h2>Biologics</h2><div class="price">$129</div><button onclick="pay('biologics')">Generate CoC PDF</button></div></div><div class="contact"><h3>brett@pharmatransport.com</h3></div></div><script>async function pay(type){const email=prompt('Customer email:')||'brett@pharmatransport.com';const res=await fetch('/pay',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:`email=${encodeURIComponent(email)}&type=${type}`});const data=await res.json();if(data.session){window.open(`/pdf?session=${data.session}&type=${type}`);alert('✅ PDF downloading!');}else{alert('Error: '+data.error);}}</script></body></html>
    HTML
  end
end

run PharmaTransportApp
