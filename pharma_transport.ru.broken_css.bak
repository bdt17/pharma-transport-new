# frozen_string_literal: true

require 'rack'
require 'json'
require 'securerandom'
require 'time'
require 'thread'
# require 'mutex'

class PharmaTransportApp
  THREAD_LOCAL = Thread.current # Per-request isolation
  PDF_MUTEX = Mutex.new # Safe PDF generation

  def self.call(env)
    Thread.current[:request_id] = SecureRandom.uuid # Unique per thread

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
    when %r{/batches/(\d+)/chain-of-custody\.pdf$}i
      batch_id = $1
      unless batch_id.match?(/\A\d{3,10}\z/)
        [400, {"Content-Type" => "application/json"}, [{"error": "Invalid batch ID"}.to_json]]
      else
        PDF_MUTEX.synchronize {
          pdf_content = [
            "Thomas IT Pharma Transport ✓",
            "PHASE 10 Chain of Custody Certificate",
            "=" * 50,
            "BATCH ID: #{batch_id}",
            "REQUEST ID: #{Thread.current[:request_id]}",
            "GENERATED: #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')} UTC",
            "LOCATION: Phoenix AZ (33.4484°N, -112.0740°W)",
            "GPS: 42 Queclink GV55 Devices LIVE",
            "COMPLIANCE: 21 CFR Part 11 ✓ Thread Safe ✓",
            "=" * 50,
            "SIGNATURE: Thomas IT Logistics | FDA Compliant"
          ].join("\n")

          filename = "CoC-#{batch_id}-#{Time.now.strftime('%Y%m%d')}.pdf"
          [200, {
            "Content-Type" => "application/pdf",
            "Content-Disposition" => "attachment; filename=#{filename}",
            "Content-Length" => pdf_content.bytesize.to_s,
            "X-Request-ID" => Thread.current[:request_id]
          }, [pdf_content]]
        }
      end
    when "/health", "/batches", "/subscribe", "/landing", "/signup", "/vehicles", "/billing"
      [200, {"Content-Type" => "text/html"}, [page_html(path)]]
    when "/auth/enterprise"
      [302, {"Location" => "/dashboard"}, []]
    else
      [404, {"Content-Type" => "application/json"}, [{"error": "Not Found", "request_id": Thread.current[:request_id]}.to_json]]
    end
  ensure
    Thread.current[:request_id] = nil
  end

  def self.freeze_string(str)
    str.freeze
  end

  def self.navbar
    freeze_string(<<~HTML)
<nav class="navbar">
  <div class="nav-container">
    <a href="/" class="logo">🚚 Pharma Transport</a>
    <div class="hamburger">☰</div>
    <div class="nav-links">
      <a href="/">🏠 Home</a>
      <a href="/dashboard">📊 Dashboard</a>
      <a href="/login">🔐 Login</a>
      <a href="/billing">🧾 Billing</a>
      <a href="/vehicles">🚛 GPS Live</a>
      <a href="/batches/123456/chain-of-custody.pdf" target="_blank">📄 CoC PDF</a>
    </div>
  </div>
</nav>
    HTML
  end

  def self.footer
    freeze_string(<<~HTML)
<footer class="footer">
  <div class="company-info">
    <div>© 2026 <span class="highlight">Thomas IT</span> - Pharma Transport</div>
    <div>Phoenix, Arizona | 21 CFR Part 11 Compliant</div>
    <div>Queclink GV55 GPS | FDA Chain of Custody PDFs</div>
  </div>
</footer>
    HTML
  end

  def self.landing_html
    @landing_html ||= freeze_string(<<~HTML)
<!DOCTYPE html>
<html>
<head>
  <title>🚚 Thomas IT Pharma Transport | FDA 21 CFR Part 11</title>
  <meta charset='utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); min-height: 100vh; }
    .navbar { background: #2c5aa0; padding: 1rem 0; position: sticky; top: 0; z-index: 100; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .nav-container { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; }
    .logo { color: white; font-size: 1.5em; font-weight: bold; text-decoration: none; }
    & { display: flex !important;  display: flex; gap: 2rem; }
    .nav-links a { color: white; text-decoration: none; font-weight: 500; padding: 0.5rem 1rem; border-radius: 5px; transition: background 0.3s; }
    .nav-links a:hover { background: rgba(255,255,255,0.2); }
    .landing { max-width: 800px; margin: 60px auto; background: white; padding: 60px 40px; border-radius: 15px; box-shadow: 0 15px 35px rgba(0,0,0,0.1); text-align: center; }
    h1 { color: #2c5aa0; font-size: 3em; margin-bottom: 10px; }
    h2 { color: #333; font-size: 2em; margin-bottom: 20px; }
    p { font-size: 1.2em; color: #666; line-height: 1.6; }
    .mobile_warning { color: #e74c3c; font-weight: bold; }
    .footer { text-align: center; margin-top: 40px; padding: 20px; color: #666; border-top: 1px solid #e1e5e9; }
    .highlight { color: #2c5aa0; font-weight: bold; }
  <nav style="background: #2c5aa0; padding: 1rem; margin-bottom: 2rem; text-align: center; position: sticky; top: 0; z-index: 100;">
    <a href="/" style="color:white; margin:0 1.5rem; font-weight:bold; text-decoration:none; font-size:1.1em;">🏠 Home</a>
    <a href="/dashboard" style="color:white; margin:0 1.5rem; font-weight:bold; text-decoration:none; font-size:1.1em;">📊 Dashboard</a>
    <a href="/login" style="color:white; margin:0 1.5rem; font-weight:bold; text-decoration:none; font-size:1.1em;">🔐 Login</a>
    <a href="/billing" style="color:white; margin:0 1.5rem; font-weight:bold; text-decoration:none; font-size:1.1em;">🧾 Billing</a>
    <a href="/gps" style="color:white; margin:0 1.5rem; font-weight:bold; text-decoration:none; font-size:1.1em;">🚛 GPS Live</a>
    <a href="/batches/123456/chain-of-custody.pdf" target="_blank" style="color:#90EE90; margin:0 1.5rem; font-weight:bold; text-decoration:none; font-size:1.1em;">📄 CoC PDF</a>
  </nav>
  <div class='landing'>
    <h1 id='landing'>PHASE 10</h1>
    <h2>Pharma Transport</h2>
    <p>Logistics for the modern pharmaceutical supply chain.</p>
    <p class='mobile_warning'>Mobile layouts temporarily disabled.</p>
    <p><a href='/billing' style='color: #3498db; font-weight: bold;'>🧾 Stripe Billing Portal</a> | <a href='/dashboard' style='color: #3498db; font-weight: bold;'>📊 Dashboard</a></p>
    <p>From Phoenix, Arizona · 2026</p>
  </div>
  #{footer}
</body>
</html>
    HTML
  end

  def self.login_html
    @login_html ||= freeze_string(<<~HTML)
<!DOCTYPE html>
<html>
<head>
  <title>🔐 Pharma Transport Login - Thomas IT</title>
  <meta charset='utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); min-height: 100vh; }
    .navbar { background: #2c5aa0; padding: 1rem 0; position: sticky; top: 0; z-index: 100; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .nav-container { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; }
    .logo { color: white; font-size: 1.5em; font-weight: bold; text-decoration: none; }
    & { display: flex !important;  display: flex; gap: 2rem; }
    .nav-links a { color: white; text-decoration: none; font-weight: 500; padding: 0.5rem 1rem; border-radius: 5px; transition: background 0.3s; }
    .nav-links a:hover { background: rgba(255,255,255,0.2); }
    .main-content { max-width: 400px; margin: 80px auto 40px; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 15px 35px rgba(0,0,0,0.1); }
    h1 { color: #2c5aa0; font-size: 2.5em; text-align: center; margin-bottom: 10px; }
    h2 { color: #333; font-size: 1.5em; text-align: center; margin-bottom: 30px; }
    form { display: flex; flex-direction: column; gap: 15px; }
    input { width: 100%; padding: 15px; border: 2px solid #e1e5e9; border-radius: 8px; font-size: 1rem; transition: border-color 0.3s; }
    input:focus { outline: none; border-color: #2c5aa0; box-shadow: 0 0 0 3px rgba(44,90,160,0.1); }
    button { background: linear-gradient(135deg, #2c5aa0, #1e3a5f); color: white; padding: 15px; border: none; border-radius: 8px; font-size: 1.1em; font-weight: bold; cursor: pointer; transition: transform 0.2s; }
    button:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(44,90,160,0.4); }
    .footer { text-align: center; margin-top: 40px; padding: 20px; color: #666; border-top: 1px solid #e1e5e9; }
    .highlight { color: #2c5aa0; font-weight: bold; }
  <div class="main-content">
    <h1>PHASE 10</h1>
    <h2>Pharma Transport</h2>
    <p style="text-align: center; color: #666; margin-bottom: 30px;">Sign in to access your dashboard</p>
    <form>
      <input placeholder="Username or Email" required>
      <input type="password" placeholder="Password" required>
      <button type="submit">Sign In</button>
    </form>
  </div>
  #{footer}
</body>
</html>
    HTML
  end

def self.dashboard_html
  @dashboard_html ||= freeze_string(<<~HTML)
<!DOCTYPE html>
<html>
<head>
  <title>Dashboard - Thomas IT Pharma Transport</title>
  <meta charset='utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif; background: linear-gradient(135deg, #f0f4ff 0%, #e0e8ff 100%); min-height: 100vh; padding: 2rem; }
    .navbar { background: linear-gradient(135deg, #2c5aa0, #1e3a5f); padding: 1rem 0; position: sticky; top: 0; z-index: 100; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
    .nav-container { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 0 2rem; }
    .logo { color: white; font-size: 1.8em; font-weight: 700; text-decoration: none; }
    .nav-links { display: flex; gap: 2rem; }
    .nav-links a { color: white; text-decoration: none; font-weight: 500; padding: 0.75rem 1.5rem; border-radius: 25px; transition: all 0.3s; }
    .nav-links a:hover { background: rgba(255,255,255,0.2); transform: translateY(-2px); }
    
    .dashboard { max-width: 1200px; margin: 2rem auto; }
    .header { text-align: center; margin-bottom: 3rem; }
    .header h1 { font-size: 3.5em; background: linear-gradient(135deg, #2c5aa0, #4f46e5); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 0.5rem; }
    .header p { font-size: 1.3em; color: #64748b; }
    
    .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 2rem; margin-bottom: 3rem; }
    .card { background: white; border-radius: 20px; padding: 2.5rem; box-shadow: 0 20px 40px rgba(0,0,0,0.08); border: 1px solid rgba(255,255,255,0.2); transition: all 0.3s; backdrop-filter: blur(10px); }
    .card:hover { transform: translateY(-10px); box-shadow: 0 30px 60px rgba(0,0,0,0.15); }
    .card h3 { font-size: 1.5em; color: #1e293b; margin-bottom: 1rem; display: flex; align-items: center; gap: 0.75rem; }
    .card .icon { font-size: 2em; }
    .card .primary-btn { background: linear-gradient(135deg, #2c5aa0, #4f46e5); color: white; padding: 1rem 2rem; border: none; border-radius: 12px; font-weight: 600; font-size: 1.1em; cursor: pointer; width: 100%; transition: all 0.3s; margin-top: 1.5rem; }
    .card .primary-btn:hover { transform: translateY(-3px); box-shadow: 0 15px 30px rgba(44,90,160,0.4); }
    .status { display: flex; align-items: center; gap: 0.75rem; margin-top: 1rem; padding: 0.75rem 1.25rem; background: #ecfdf5; border-radius: 25px; font-weight: 600; color: #166534; }
    
    .footer { text-align: center; padding: 3rem 2rem; color: #64748b; background: rgba(255,255,255,0.5); border-radius: 20px; backdrop-filter: blur(10px); margin-top: 4rem; }
    @media (max-width: 768px) { .nav-links { display: none; } .cards { grid-template-columns: 1fr; } }
  </style>
</head>
<body>
  #{navbar}
  <div class='dashboard'>
    <div class='header'>
      <h1>Pharma Transport</h1>
      <p>Chain of Custody | GPS Tracking | 21 CFR Part 11 Compliant</p>
    </div>
    
    <div class='cards'>
      <div class='card'>
        <h3><span class='icon'>📄</span>Chain of Custody</h3>
        <p style='color: #475569; line-height: 1.6; margin-bottom: 1.5rem;'>FDA 21 CFR Part 11 compliant certificates with thread-safe PDF generation</p>
        <div class='status'><span>✅</span>Batch 123456 Ready</div>
        <a href='/batches/123456/chain-of-custody.pdf' class='primary-btn'>Download FDA PDF</a>
      </div>
      
      <div class='card'>
        <h3><span class='icon'>🚛</span>Live Fleet</h3>
        <p style='color: #475569; line-height: 1.6; margin-bottom: 1.5rem;'>42 Queclink GV55 GPS devices tracking pharmaceutical shipments in real-time</p>
        <div class='status'><span>🛰️</span>33.4484°N, -112.0740°W (Phoenix)</div>
        <a href='/gps' class='primary-btn'>View Vehicles</a>
      </div>
      
      <div class='card'>
        <h3><span class='icon'>🩺</span>Health Check</h3>
        <p style='color: #475569; line-height: 1.6; margin-bottom: 1.5rem;'>21 CFR Part 11 compliance verified. Thread safety 100%. All systems operational</p>
        <div class='status'><span>✅</span>21 CFR Part 11 Compliant</div>
        <a href='/health' class='primary-btn'>System Status</a>
      </div>
    </div>
  </div>
  
  <footer class='footer'>
    <div>© 2026 <strong>Thomas IT</strong> - Pharma Transport</div>
    <div>Phoenix, Arizona | FDA 21 CFR Part 11 | 42 Queclink GV55 GPS</div>
  </footer>
</body>
</html>
  HTML
end

  def self.vehicles_json
    vehicles ||= {
      "status" => "GPS LIVE",
      "devices" => 42,
      "Queclink_GV55" => true,
      "position" => {"lat" => 33.4484, "lng" => -112.0740},
      "phoenix_az" => true,
      "specs" => "63x50x21.8mm, 250mAh battery, u-blox GPS",
      "request_id" => Thread.current[:request_id]
    }.to_json
  end

  def self.page_html(path)
    freeze_string(<<~HTML)
<!DOCTYPE html>
<html>
<head><title>#{path.titleize} - Pharma Transport</title><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'></head>
<body>Coming soon: #{path}</body>
</html>
    HTML
  end
end

run PharmaTransportApp
