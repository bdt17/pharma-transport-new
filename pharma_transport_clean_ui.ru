# frozen_string_literal: true

require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'thread'

class PharmaTransportApp
  PDF_MUTEX = Mutex.new

  def self.call(env)
    Thread.current[:request_id] = SecureRandom.uuid

    path = env["PATH_INFO"]
    case path
    when "/favicon.ico"
      [204, {}, []]
    when "/"
      [200, {"Content-Type" => "text/html; charset=utf-8"}, [landing_html]]
    when "/dashboard"
      [200, {"Content-Type" => "text/html; charset=utf-8"}, [dashboard_html]]
    when "/gps"
      # Your existing GPS handler - returns JSON with 42 devices
      gps_data = { "devices" => 42 }  # Placeholder; use your real logic
      [200, {"Content-Type" => "application/json"}, [gps_data.to_json]]
    else
      [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
    end
  end

  def self.landing_html
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>🚚 Thomas IT Pharma Transport | FDA 21 CFR Part 11</title>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); 
            min-height: 100vh; 
          }
          .navbar { 
            background: #2c5aa0; padding: 1rem 0; 
            position: sticky; top: 0; z-index: 100; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
          }
          .nav-container { 
            max-width: 1200px; margin: 0 auto; 
            display: flex; justify-content: space-between; align-items: center; 
            padding: 0 20px; 
          }
          .logo { 
            color: white; font-size: 1.5em; font-weight: bold; 
            text-decoration: none; 
          }
          .nav-links { 
            display: flex; gap: 2rem; 
          }
          .nav-links a { 
            color: white; text-decoration: none; font-weight: 500; 
            padding: 0.5rem 1rem; border-radius: 5px; 
            transition: background 0.3s; 
          }
          .nav-links a:hover { background: rgba(255,255,255,0.2); }
          .landing { 
            max-width: 800px; margin: 60px auto; 
            background: white; padding: 60px 40px; 
            border-radius: 15px; box-shadow: 0 15px 35px rgba(0,0,0,0.1); 
            text-align: center; 
          }
          h1 { color: #2c5aa0; font-size: 3em; margin-bottom: 10px; }
          h2 { color: #333; font-size: 2em; margin-bottom: 20px; }
          p { font-size: 1.2em; color: #666; line-height: 1.6; }
          .mobile_warning { color: #e74c3c; font-weight: bold; }
        </style>
      </head>
      <body>
        <nav class="navbar">
          <div class="nav-container">
            <a href="/" class="logo">🚚 Pharma Transport</a>
            <div class="nav-links">
              <a href="/dashboard">Dashboard</a>
              <a href="/gps">GPS Tracking</a>
            </div>
          </div>
        </nav>
        <section class="landing">
          <h1>Pharma Transport</h1>
          <h2>Logistics for the modern pharmaceutical supply chain.</h2>
          <p>FDA 21 CFR Part 11 compliant. Real-time GPS tracking for 42+ devices.</p>
          <p class="mobile_warning">Optimized for desktop. Mobile view coming soon.</p>
        </section>
        <div style="text-align: center; margin-top: 40px; color: #666;">
          © 2026 Thomas IT - Pharma Transport
        </div>
      </body>
    HTML
  end

  def self.dashboard_html
    # Inline your dashboard HTML here, or load from file
    landing_html  # Placeholder; expand with real dashboard
  end
end

run PharmaTransportApp
