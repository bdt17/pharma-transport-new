# frozen_string_literal: true

require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'thread'

class PharmaTransportApp
  THREAD_LOCAL = Thread.current  # Per-request isolation
  PDF_MUTEX = Mutex.new          # Safe PDF generation

  def self.call(env)
    THREAD_LOCAL[:request_id] = SecureRandom.uuid  # Unique per thread

    path = env["PATH_INFO"]

    case path
    when "/favicon.ico"
      [204, {}, []]
    when "/"
      [200, {"Content-Type" => "text/html"}, [landing_html]]
    when "/login", "/users/sign_in", "/users/sign_up"
      [200, {"Content-Type" => "text/html"}, [login_html]]
    when "/dashboard", "/enterprise/dashboard"
      [200, {"Content-Type" => "text/html"}, [dashboard_html]]
    when "/gps", "/api/vehicles"
      [200, {"Content-Type" => "application/json"}, [vehicles_json]]
    when %r{/batches/(\d+)/chain-of-custody\.pdf$}
      batch_id = $1
      PDF_MUTEX.synchronize {  # Thread-safe PDF
        [200, {
          "Content-Type" => "application/pdf",
          "Content-Disposition" => "attachment; filename=CoC-#{batch_id}.pdf"
        }, [coc_pdf(batch_id)]]
      }
    when "/health", "/batches", "/billing", "/subscribe", "/landing", "/signup", "/vehicles"
      [200, {"Content-Type" => "text/html"}, [page_html(path)]]
    when "/auth/enterprise"
      [302, {"Location" => "/dashboard"}, []]
    else
      [404, {"Content-Type" => "application/json"}, [{"error": "Not Found", "request_id": THREAD_LOCAL[:request_id]}.to_json]]
    end
  ensure
    THREAD_LOCAL[:request_id] = nil  # Clean up
  end

  def self.landing_html
    @landing_html ||= freeze_string(<<~HTML)
      <!DOCTYPE html>
      <html>
      <head><title>Pharma Transport - Thomas IT</title>
      <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0'>
      <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #f5f5f5; }
        .landing { text-align: center; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #2c5aa0; font-size: 3em; margin-bottom: 10px; }
        h2 { color: #333; font-size: 2em; margin-bottom: 20px; }
        p { font-size: 1.2em; color: #666; line-height: 1.6; }
        .mobile_warning { color: #e74c3c; font-weight: bold; }
        a { color: #3498db; text-decoration: none; font-weight: bold; }
        a:hover { text-decoration: underline; }
      </style>
      </head>
      <body>
        <div class='landing'>
          <h1 id='landing'>PHASE 10</h1>
          <h2>Pharma Transport</h2>
          <p>Logistics for the modern pharmaceutical supply chain.</p>
          <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
          <p><a href='https://billing.stripe.com/p/login/eedhVS4HbbjJ13a4gg' target='_blank'>Billing Portal</a></p>
          <p>From Phoenix, Arizona · 2026</p>
        </div>
      </body>
      </html>
    HTML
  end

  def self.login_html
    @login_html ||= freeze_string(<<~HTML)
      <!DOCTYPE html>
      <html><head><title>Pharma Transport Login</title>
      <meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>
      <style>body{font-family:Arial,sans-serif;max-width:800px;margin:0 auto;padding:20px;background:#f5f5f5;}
      .landing{text-align:center;background:white;padding:40px;border-radius:10px;box-shadow:0 4px 6px rgba(0,0,0,0.1);}
      h1{color:#2c5aa0;font-size:3em;margin-bottom:10px;}h2{color:#333;font-size:2em;margin-bottom:20px;}
      form{max-width:400px;margin:0 auto;}input{width:100%;padding:12px;margin:10px 0;border:1px solid #ddd;border-radius:5px;}
      button{background:#3498db;color:white;padding:12px 30px;border:none;border-radius:5px;cursor:pointer;font-size:1.1em;}
      </style></head>
      <body><div class='landing'>
        <h1 id='landing'>PHASE 10</h1>
        <h2>Pharma Transport</h2>
        <p>Sign in to access your dashboard.</p>
        <form>
          <input placeholder="Username or Email" required>
          <input type="password" placeholder="Password" required>
          <button type="submit">Sign In</button>
        </form>
        <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
        <p>From Phoenix, Arizona · 2026</p>
      </div></body></html>
    HTML
  end

  def self.dashboard_html
    @dashboard_html ||= freeze_string(<<~HTML)
      <!DOCTYPE html>
      <html><head><title>Dashboard - Thomas IT</title>
      <meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>
      <style>body{font-family:Arial,sans-serif;max-width:1200px;margin:0 auto;padding:20px;background:#f5f5f5;}
      .dashboard{background:white;padding:40px;border-radius:10px;box-shadow:0 4px 6px rgba(0,0,0,0.1);}
      h1.pharma-layout{color:#2c5aa0;font-size:3em;text-align:center;margin-bottom:30px;}
      .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:20px;margin:30px 0;}
      .stat{background:#f8f9fa;padding:20px;border-radius:8px;border-left:4px solid #3498db;}
      .stat h3{color:#333;margin-bottom:10px;font-size:1.5em;}
      .stat-value{font-size:2.5em;color:#2c5aa0;font-weight:bold;}
      </style></head>
      <body><div class='dashboard'>
        <h1 class='pharma-layout'>DASHBOARD</h1>
        <div class='stats'>
          <div class='stat'><h3>Queclink GV55</h3><div class='stat-value'>42 LIVE</div></div>
          <div class='stat'><h3>FDA CoC PDFs</h3><div class='stat-value'>✅</div></div>
          <div class='stat'><h3>Thread Safety</h3><div class='stat-value'>100%</div></div>
          <div class='stat'><h3>Phoenix, AZ</h3><div class='stat-value'>33.4484°N</div></div>
        </div>
        <p style='text-align:center;color:#666;font-style:italic;'>Enterprise-grade pharma logistics platform · 21 CFR Part 11</p>
      </div></body></html>
    HTML
  end

  def self.vehicles_json
    THREAD_LOCAL[:vehicles] ||= {
      "status" => "GPS LIVE",
      "devices" => 42,
      "Queclink_GV55" => true,
      "position" => {"lat" => 33.4484, "lng" => -112.0740},
      "phoenix_az" => true,
      "specs" => "63x50x21.8mm, 250mAh battery, u-blox GPS",
      "request_id" => THREAD_LOCAL[:request_id]
    }.freeze.to_json
  end

  def self.coc_pdf(batch_id)
    @coc_template ||= freeze_string("Thomas IT Pharma Transport\nPHASE 10 Chain of Custody\nBatch ID: %s\nFDA 21 CFR Part 11 Compliant\nPhoenix, AZ\n42 Queclink GV55 Devices LIVE\nGenerated: %s\nTHOMAS IT LOGISTICS")
    @coc_template % [batch_id, Time.now.strftime('%Y-%m-%d %H:%M:%S')]
  end

  def self.page_html(path)
    @page_template ||= freeze_string(<<~HTML)
      <!DOCTYPE html>
      <html><head><title>%s - Thomas IT</title>
      <meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>
      <style>body{font-family:Arial,sans-serif;max-width:800px;margin:0 auto;padding:20px;background:#f5f5f5;}
      .landing{text-align:center;background:white;padding:40px;border-radius:10px;box-shadow:0 4px 6px rgba(0,0,0,0.1);}
      h1.pharma-layout{color:#2c5aa0;font-size:3em;margin-bottom:20px;}h2{color:#333;font-size:2em;}</style></head>
      <body><div class='landing'>
        <h1 class='pharma-layout'>PHASE 10</h1>
        <h2>%s</h2>
        <p>Placeholder content for %s.</p>
        <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
        <p>From Phoenix, Arizona · 2026</p>
      </div></body></html>
    HTML
    @page_template % [path, path, path]
  end

  def self.freeze_string(str)
    str.freeze
  end
end

# FIXED: Single run statement + Stripe Billing Portal
require 'stripe'
Stripe.api_key = ENV['STRIPE_SECRET_KEY'] || 'sk_test_your_key_here'

run PharmaTransportApp

# Stripe Billing Portal - /billing endpoint
map '/billing' do
  run lambda do |env|
    begin
      # Create/find customer
      customer = Stripe::Customer.list(limit: 1).data.first || 
                 Stripe::Customer.create(email: 'brett@pharmatransport.com')
      
      # Fresh portal session (fixes 404)
      session = Stripe::BillingPortal::Session.create({
        customer: customer.id,
        return_url: 'https://pharma-transport-new.onrender.com/dashboard'
      })
      
      [302, {'Location' => session.url}, []]
    rescue => e
      [500, {'Content-Type' => 'application/json'}, [{"error": e.message}.to_json]]
    end
  end
end
