# frozen_string_literal: true

require 'rack'
require 'json'
require 'time'
require 'thread'

class PharmaTransportApp
  THREAD_LOCAL = Thread.current  # Per-request isolation [web:12]
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
      PDF_MUTEX.synchronize {  # Thread-safe PDF [web:11]
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
    THREAD_LOCAL[:request_id] = nil  # Clean up [web:13]
  end

  def self.landing_html
    @landing_html ||= freeze_string(<<~HTML)
      <!DOCTYPE html>
      <html>
      <head><title>Pharma Transport - Thomas IT</title>
      <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0'>
      <style>/* Your existing CSS */</style>
      </head>
      <body><div class='landing'>
        <h1 id='landing'>PHASE 10</h1>
        <h2>Pharma Transport</h2>
        <p>Logistics for the modern pharmaceutical supply chain.</p>
        <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
        <p><a href='https://billing.stripe.com/p/login/eedhVS4HbbjJ13a4gg' target='_blank'>Billing</a></p>
        <p>From Phoenix, Arizona · 2026</p>
      </div></body>
      </html>
    HTML
  end

  def self.login_html
    @login_html ||= freeze_string(<<~HTML)
      <!DOCTYPE html>
      <html><head><title>Pharma Transport Login</title><!-- Same head as landing --></head>
      <body><div class='landing'>
        <h1 id='landing'>PHASE 10</h1>
        <h2>Pharma Transport</h2>
        <p>Sign in to access your dashboard.</p>
        <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
        <p>From Phoenix, Arizona · 2026</p>
      </div></body>
      </html>
    HTML
  end

  def self.dashboard_html
    @dashboard_html ||= freeze_string(<<~HTML)
      <!DOCTYPE html>
      <html><head><title>Dashboard - Thomas IT</title><!-- Same head --></head>
      <body><div class='dashboard'>
        <h1 class='pharma-layout'>DASHBOARD</h1>
        <p>Enterprise‑grade pharma logistics platform.</p>
        <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
      </div></body>
      </html>
    HTML
  end

  def self.vehicles_json
    THREAD_LOCAL[:vehicles] ||= {
      "status" => "GPS LIVE",
      "devices" => 42,
      "Queclink_GV55" => true,
      "position" => {"lat" => 33.4484, "lng" => -112.0740},
      "phoenix_az" => true,
      "specs" => "63x50x21.8mm, 250mAh battery, u‑blox GPS",
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
      <html><head><title>%s - Thomas IT</title><!-- Same head --></head>
      <body><div class='landing'>
        <h1 class='pharma-layout'>PHASE 10</h1>
        <h2>%s</h2>
        <p>Placeholder content for %s.</p>
        <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
        <p>From Phoenix, Arizona · 2026</p>
      </div></body>
      </html>
    HTML
    @page_template % [path, path, path]
  end

  def self.freeze_string(str)
    str.freeze
  end
end

run PharmaTransportApp
