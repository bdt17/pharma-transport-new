#!/usr/bin/env ruby
require 'bundler/setup'
require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'base64'
require 'cgi'
require 'openssl'
require 'webrick'

class PharmaTransportProPortal
  SECRET = 'bannerhealth2026_secret_pro'.freeze
  SESSION_KEY = '_pharma_session'.freeze
  
  VALID_PAYMENTS = {
    'bannerhealth' => { hospital: 'Banner Health', amount: 15000, status: 'paid', date: Time.now.to_s },
    'phxtest' => { hospital: 'Phoenix General', amount: 5000, status: 'paid', date: Time.now.to_s }
  }.freeze

  VALID_USERS = {
    'director@bannerhealth.com' => 'banner2026',
    'admin@pharmatransport.com' => 'pro2026'
  }.freeze

  def initialize
    @server = nil
  end

  def call(env)
    @request = Rack::Request.new(env)
    @session = parse_session(env['HTTP_COOKIE'])
    @session_changed = false
    response = dispatch
    if @session_changed
      response[1]['Set-Cookie'] = "#{SESSION_KEY}=#{encode_session(@session)}; Path=/; HttpOnly; Secure; SameSite=Strict"
    end
    response
  end

  def dispatch
    case @request.path
    when '/' then [200, {'Content-Type' => 'text/html; charset=utf-8'}, [landing_html]]
    when '/login' then handle_login
    when '/dashboard' then require_auth { [200, {'Content-Type' => 'text/html; charset=utf-8'}, [dashboard_html]] }
    when '/history' then require_auth { [200, {'Content-Type' => 'text/html; charset=utf-8'}, [history_html]] }
    when '/generate_pdf' then require_auth { [200, {'Content-Type' => 'text/html; charset=utf-8'}, [pdf_html]] }
    when '/handle_payment' then handle_payment
    else [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
    end
  end

  def parse_session(cookie)
    return {} unless cookie
    cookie.scan(/#{SESSION_KEY}=([^;]+)/).flatten.first&.then do |value|
      begin
        data = Base64.urlsafe_decode64(value)
        json, signature = data.split('--', 2)
        return {} unless json && signature
        computed = OpenSSL::HMAC.hexdigest('SHA256', SECRET, json)
        secure_compare(signature, computed) ? JSON.parse(json, symbolize_names: true) || {} : {}
      rescue; {}; end
    end || {}
  end

  def encode_session(session_data)
    json = session_data.to_json
    signature = OpenSSL::HMAC.hexdigest('SHA256', SECRET, json)
    Base64.urlsafe_encode64("#{json}--#{signature}")
  end

  def secure_compare(a, b)
    return false unless a && b && a.bytesize == b.bytesize
    l = a.unpack("C#{a.bytesize}")
    accumulator = 0
    b.each_byte { |byte| accumulator |= byte ^ l.shift }
    accumulator == 0
  end

  def mark_session_changed
    @session_changed = true
  end

  def handle_login
    return [200, {'Content-Type' => 'text/html; charset=utf-8'}, [login_html]] unless @request.post?
    email = CGI.unescape(@request.params['email'] || '')
    password = CGI.unescape(@request.params['password'] || '')
    if VALID_USERS[email] && VALID_USERS[email] == password
      @session['logged_in'] = true
      @session['email'] = email
      mark_session_changed
      [302, {'Location' => '/dashboard'}, []]
    else
      [200, {'Content-Type' => 'text/html; charset=utf-8'}, [login_html('Invalid credentials')]]
    end
  end

  def require_auth
    if @session['logged_in'] || @request.params['demo']
      yield
    else
      [302, {'Location' => "/login?from=#{CGI.escape(@request.path)}"}, []]
    end
  end

  def handle_payment
    payment_id = @request.params['payment_id']
    if VALID_PAYMENTS[payment_id]
      payment = VALID_PAYMENTS[payment_id]
      @session['payment'] = payment
      mark_session_changed
      [200, {'Content-Type' => 'text/html; charset=utf-8'}, [payment_success_html(payment)]]
    else
      [400, {'Content-Type' => 'text/html; charset=utf-8'}, ['Invalid payment']]
    end
  end

  private

  def landing_html
    <<~HTML
      <!DOCTYPE html>
      <html><head><title>Pharma Transport PRO</title>
      <style>body{font-family:Arial,sans-serif;max-width:800px;margin:50px auto;padding:20px;background:#f5f5f5;}
      .hero{background:#007bff;color:white;padding:40px;border-radius:10px;text-align:center;}
      .btn{display:inline-block;padding:12px 24px;background:#28a745;color:white;text-decoration:none;border-radius:5px;}
      form{display:inline;}</style></head>
      <body>
        <div class="hero">
          <h1>🚚 Pharma Transport PRO</h1>
          <p>FDA-Compliant Logistics Dashboard - $15K/mo Banner Health</p>
          <a href="/login" class="btn">Login → Director Portal</a>
          <a href="/dashboard?demo=1" class="btn">Demo Dashboard</a>
        </div>
      </body></html>
    HTML
  end

  def login_html(error = nil)
    <<~HTML
      <!DOCTYPE html>
      <html><head><title>Login - Pharma Transport PRO</title>
      <style>body{font-family:Arial,sans-serif;max-width:400px;margin:100px auto;padding:20px;background:#f5f5f5;}
      input,button{width:100%;padding:12px;margin:8px 0;font-size:16px;}
      button{background:#007bff;color:white;border:none;border-radius:5px;cursor:pointer;}
      .error{color:#dc3545;}</style></head>
      <body>
        <h2>Pharma Transport PRO Login</h2>
        #{error ? "<p class='error'>#{error}</p>" : ''}
        <form method='POST'>
          <input type='email' name='email' placeholder='director@bannerhealth.com' required>
          <input type='password' name='password' placeholder='Password' required>
          <button type='submit'>Login</button>
        </form>
        <p><a href='/'>← Back to Landing</a></p>
      </body></html>
    HTML
  end

  def dashboard_html
    payment = @session['payment']
    <<~HTML
      <!DOCTYPE html>
      <html><head><title>Dashboard - Pharma Transport PRO</title>
      <style>body{font-family:Arial,sans-serif;max-width:1000px;margin:50px auto;padding:20px;background:#f5f5f5;}
      .header{background:#007bff;color:white;padding:20px;border-radius:10px;}
      .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin:20px 0;}
      .card{background:white;padding:20px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1);}
      .btn{display:inline-block;padding:10px 20px;background:#28a745;color:white;text-decoration:none;border-radius:5px;}</style></head>
      <body>
        <div class="header">
          <h1>📊 Pharma Transport Dashboard</h1>
          <p>Welcome, #{@session['email']} | <a href='/logout' style='color:#fff;'>Logout</a></p>
        </div>
        <div class="stats">
          <div class="card"><h3>💰 Revenue</h3><p>#{payment ? '$' + payment[:amount].to_s : '$15,000'}</p></div>
          <div class="card"><h3>🏥 Clients</h3><p>Banner Health<br>Phoenix General</p></div>
          <div class="card"><h3>🚚 Active Shipments</h3><p>47 Biologics<br>12 Vaccines</p></div>
          <div class="card"><h3>✅ FDA Compliance</h3><p>100% Compliant<br>21 CFR Part 11</p></div>
        </div>
        <a href='/history' class="btn">📋 Shipment History</a>
        <a href='/generate_pdf' class="btn">📄 Generate FDA PDF</a>
      </body></html>
    HTML
  end

  def history_html
    <<~HTML
      <!DOCTYPE html>
      <html><head><title>History - Pharma Transport PRO</title>
      <style>body{font-family:Arial,sans-serif;max-width:1000px;margin:50px auto;padding:20px;background:#f5f5f5;}
      table{width:100%;border-collapse:collapse;margin:20px 0;background:white;border-radius:8px;overflow:hidden;box-shadow:0 2px 10px rgba(0,0,0,0.1);}
      th,td{padding:12px;text-align:left;border-bottom:1px solid #eee;}
      th{background:#007bff;color:white;}</style></head>
      <body>
        <h1>📋 Shipment History</h1>
        <table>
          <tr><th>Hospital</th><th>Product</th><th>Date</th><th>Status</th></tr>
          <tr><td>Banner Health</td><td>Biologics 129</td><td>#{Time.now.strftime('%Y-%m-%d')}</td><td>✅ Delivered</td></tr>
          <tr><td>Phoenix General</td><td>Vaccines</td><td>#{Time.now.strftime('%Y-%m-%d')}</td><td>✅ Delivered</td></tr>
        </table>
        <a href='/dashboard'>← Back to Dashboard</a>
      </body></html>
    HTML
  end

  def pdf_html
    <<~HTML
      <!DOCTYPE html>
      <html><head><title>FDA PDF Generator</title>
      <style>body{font-family:Arial,sans-serif;max-width:600px;margin:50px auto;padding:20px;background:#f5f5f5;}
      .pdf-ready{background:#d4edda;border:1px solid #c3e6cb;padding:20px;border-radius:8px;}
      .btn{display:inline-block;padding:12px 24px;background:#28a745;color:white;text-decoration:none;border-radius:5px;}</style></head>
      <body>
        <h1>📄 FDA Compliance PDF</h1>
        <div class="pdf-ready">
          <h3>✅ Ready for Print</h3>
          <p>Banner Health Biologics Shipment #129<br>21 CFR Part 11 Compliant</p>
          <p><strong>Date:</strong> #{Time.now.strftime('%Y-%m-%d %H:%M')}</p>
        </div>
        <p><a href='/dashboard' class="btn">← Back to Dashboard</a></p>
      </body></html>
    HTML
  end

  def payment_success_html(payment)
    <<~HTML
      <!DOCTYPE html>
      <html><head><title>Payment Success</title>
      <style>body{font-family:Arial,sans-serif;max-width:500px;margin:100px auto;padding:20px;text-align:center;background:#f5f5f5;}
      .success{background:#d4edda;border:3px solid #28a745;padding:40px;border-radius:10px;}
      h1{color:#28a745;font-size:2em;}</style></head>
      <body>
        <div class="success">
          <h1>✅ Payment Complete!</h1>
          <p>#{payment[:hospital]}</p>
          <p><strong>$${payment[:amount].to_s}</strong> - #{payment[:status].upcase}</p>
          <p>Date: #{payment[:date]}</p>
          <a href='/dashboard' style='display:inline-block;padding:12px 24px;background:#007bff;color:white;text-decoration:none;border-radius:5px;'>→ Dashboard</a>
        </div>
      </body></html>
    HTML
  end
end

# Start server directly (no rackup needed)
app = PharmaTransportProPortal.new
Rack::Handler::WEBrick.run app, Port: ENV['PORT'] || 10000, Host: '0.0.0.0', AccessLog: [], Logger: WEBrick::Log.new('/dev/null')
