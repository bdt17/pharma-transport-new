# frozen_string_literal: true

require 'rack'
require 'json'
require 'securerandom'

class PharmaTransportApp
  def self.call(env)
    path = env["PATH_INFO"]
    case path
    when "/favicon.ico" then [204, {}, []]
    when "/" then [200, {"Content-Type" => "text/html; charset=utf-8"}, [landing_page]]
    when "/dashboard" then [200, {"Content-Type" => "text/html; charset=utf-8"}, [dashboard_page]]
    when "/gps" 
      [200, {"Content-Type" => "application/json"}, [{'devices' => 42}.to_json]]
    else [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
    end
  end

  def self.landing_page
    <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>🚚 Thomas IT Pharma Transport | FDA 21 CFR Part 11</title>
  <meta charset='utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <style>
    *{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:Arial,sans-serif;background:linear-gradient(135deg,#f5f7fa 0%,#c3cfe2 100%);min-height:100vh;}
    .navbar{background:#2c5aa0;padding:1rem 0;position:sticky;top:0;z-index:100;box-shadow:0 2px 10px rgba(0,0,0,0.1);}
    .nav-container{max-width:1200px;margin:0 auto;display:flex;justify-content:space-between;align-items:center;padding:0 20px;}
    .logo{color:white;font-size:1.5em;font-weight:bold;text-decoration:none;}
    .nav-links{display:flex;gap:2rem;}
    .nav-links a{color:white;text-decoration:none;font-weight:500;padding:.5rem 1rem;border-radius:5px;transition:background .3s;}
    .nav-links a:hover{background:rgba(255,255,255,0.2);}
    .landing{max-width:800px;margin:60px auto;background:white;padding:60px 40px;border-radius:15px;box-shadow:0 15px 35px rgba(0,0,0,0.1);text-align:center;}
    h1{color:#2c5aa0;font-size:3em;margin-bottom:10px;}
    h2{color:#333;font-size:2em;margin-bottom:20px;}
    p{font-size:1.2em;color:#666;line-height:1.6;}
  </style>
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="logo">🚚 Pharma Transport</a>
      <div class="nav-links">
        <a href="/dashboard">Dashboard</a>
        <a href="/gps">GPS (42 devices)</a>
      </div>
    </div>
  </nav>
  <section class="landing">
    <h1>Pharma Transport</h1>
    <h2>Phase 10 Production</h2>
    <p>FDA 21 CFR Part 11 | 42 GPS Devices Live | 99.9% Uptime</p>
  </section>
</body>
</html>
    HTML
  end

  def self.dashboard_page
    landing_page.gsub('Phase 10 Production','Dashboard Active')
  end
end

run PharmaTransportApp
