#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'prawn'
require 'stripe'

Stripe.api_key = ENV['STRIPE_SECRET_KEY']

class PharmaTransportApp
  PRICES = {'insulin'=>4900,'vaccines'=>7900,'biologics'=>12900}.freeze # cents

  def self.call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path]
    when ['GET', '/'] then [200,{'Content-Type'=>'text/html'},[html_dashboard]]
    when ['POST', '/pay']
      params = Rack::Utils.parse_query(req.body.read)
      type = params['type']&.downcase
      email = params['email']
      
      return [400,{'Content-Type'=>'application/json'},[{"error"=>"Invalid type"}.to_json]] unless PRICES[type]
      
      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        customer_email: email,
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {name: "#{type.capitalize} CoC"},
            unit_amount: PRICES[type]
          },
          quantity: 1
        }],
        mode: 'payment',
        success_url: "#{req.scheme}://#{req.host}/?success=true",
        cancel_url: "#{req.scheme}://#{req.host}/"
      })
      
      session_id = session.id
      [200,{'Content-Type'=>'application/json'},[{"url"=>session.url,"session"=>session_id}.to_json]]
    when ['GET', '/pdf']
      # Mock PDF for now (add Stripe verification later)
      type = req.params['type']
      session_id = "sess_#{SecureRandom.hex(8)}"
      
      pdf = Prawn::Document.new
      pdf.text "CHAIN OF CUSTODY - #{type.upcase}", size: 24
      pdf.text "Stripe Session: #{session_id}", size: 14
      pdf.text "21 CFR PART 11", style: :bold
      
      [200,{
        'Content-Type'=>'application/pdf',
        'Content-Disposition'=>"attachment; filename=#{type}_coc.pdf"
      },[pdf.render]]
    else [404,{},['Not Found']]
    end
  end

  def self.html_dashboard
    '<!DOCTYPE html><html><head><title>Pharma Transport</title><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:system-ui;background:linear-gradient(135deg,#1e3a8a 0%,#3b82f6 100%);color:white;min-height:100vh;padding:1rem;}h1{text-align:center;font-size:clamp(2rem,5vw,3.5rem);}</style></head><body><h1>🚚 Pharma Transport</h1><div style="display:grid;grid-template-columns:repeat(3,1fr);gap:2rem;max-width:1200px;margin:2rem auto;"><div style="background:rgba(255,255,255,0.1);padding:2rem;border-radius:1rem;text-align:center;"><h2>Insulin $49</h2><button onclick="pay(\'insulin\')" style="background:linear-gradient(45deg,#10b981,#059669);color:white;border:none;padding:1rem 2rem;border-radius:8px;font-size:1.1rem;cursor:pointer;">Pay with Stripe</button></div><div style="background:rgba(255,255,255,0.1);padding:2rem;border-radius:1rem;text-align:center;"><h2>Vaccines $79</h2><button onclick="pay(\'vaccines\')" style="background:linear-gradient(45deg,#10b981,#059669);color:white;border:none;padding:1rem 2rem;border-radius:8px;font-size:1.1rem;cursor:pointer;">Pay with Stripe</button></div><div style="background:rgba(255,255,255,0.1);padding:2rem;border-radius:1rem;text-align:center;"><h2>Biologics $129</h2><button onclick="pay(\'biologics\')" style="background:linear-gradient(45deg,#10b981,#059669);color:white;border:none;padding:1rem 2rem;border-radius:8px;font-size:1.1rem;cursor:pointer;">Pay with Stripe</button></div></div><script>async function pay(t){const e=prompt("Customer email:")||\'brett@pharmatransport.com\';const r=await fetch("/pay",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded"},body:`email=${encodeURIComponent(e)}&type=${t}`});const d=await r.json();if(d.url){window.location.href=d.url;alert("Redirecting to Stripe...");}else{alert("Error: "+d.error);}}</script></body></html>'
  end
end

run PharmaTransportApp
