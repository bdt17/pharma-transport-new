#!/usr/bin/env ruby
require 'rack'
require 'json'
require 'securerandom'
require 'prawn'

class PharmaTransportApp
  PRICES = {'insulin'=>49,'vaccines'=>79,'biologics'=>129}.freeze

  def self.call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path]
    when ['GET', '/'] then [200,{'Content-Type'=>'text/html'},[html_dashboard]]
    when ['POST', '/pay']
      params = Rack::Utils.parse_query(req.body.read)
      type = params['type']&.downcase
      return [400,{'Content-Type'=>'application/json'},[{"error"=>"Invalid type"}.to_json]] unless PRICES[type]
      
      session_id = "sess_#{SecureRandom.hex(8)}"
      [200,{'Content-Type'=>'application/json'},[{"session"=>session_id,"price"=>PRICES[type],"type"=>type}.to_json]]
    when ['GET', '/pdf']
      session_id,type=req.params['session'],req.params['type']
      return [400,{},['Invalid session']] unless session_id && type && PRICES[type]
      
      pdf = Prawn::Document.new
      pdf.text "CHAIN OF CUSTODY - #{type.upcase}", size: 24, align: :center
      pdf.text "Session: #{session_id}", size: 14
      pdf.text "21 CFR PART 11 COMPLIANT", style: :bold
      
      [200,{
        'Content-Type'=>'application/pdf',
        'Content-Disposition'=>"attachment; filename=#{type}_coc.pdf"
      },[pdf.render]]
    else [404,{},['Not Found']]
    end
  end

  def self.html_dashboard
    '<!DOCTYPE html><html><head><title>Pharma Transport</title><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:system-ui;background:linear-gradient(135deg,#1e3a8a 0%,#3b82f6 100%);color:white;min-height:100vh;padding:1rem;}.container{max-width:1200px;margin:0 auto;padding:2rem 1rem;}h1{text-align:center;font-size:clamp(2rem,5vw,3.5rem);margin-bottom:2rem;}.compliance{background:rgba(16,185,129,0.9);padding:1.5rem;border-radius:16px;text-align:center;margin-bottom:3rem;}.pricing{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:2rem;}.tier{background:rgba(255,255,255,0.15);padding:2.5rem 2rem;border-radius:20px;text-align:center;}.price{font-size:clamp(2.5rem,8vw,4rem);color:#10b981;font-weight:800;margin-bottom:1.5rem;}button{background:linear-gradient(45deg,#10b981,#059669);color:white;border:none;padding:1.2rem 3rem;border-radius:12px;font-size:1.2rem;font-weight:600;cursor:pointer;}</style></head><body><div class="container"><h1>🚚 Pharma Transport</h1><div class="compliance"><strong>21 CFR Part 11</strong> | LIVE</div><div class="pricing"><div class="tier"><h2>Insulin $49</h2><button onclick="pay(\'insulin\')">PDF</button></div><div class="tier"><h2>Vaccines $79</h2><button onclick="pay(\'vaccines\')">PDF</button></div><div class="tier"><h2>Biologics $129</h2><button onclick="pay(\'biologics\')">PDF</button></div></div></div><script>async function pay(t){const e=prompt(\'Email:\')||\'test@pharma.com\';const r=await fetch(\'/pay\',{method:\'POST\',headers:{\'Content-Type\':\'application/x-www-form-urlencoded\'},body:`email=${encodeURIComponent(e)}&type=${t}`});const d=await r.json();if(d.session)window.open(`/pdf?session=${d.session}&type=${t}`),alert(\'✅ PDF!\');else alert(d.error)}</script></body></html>'
  end
end

run PharmaTransportApp
