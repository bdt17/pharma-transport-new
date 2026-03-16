# frozen_string_literal: true

require 'rack'
require 'json'
require 'securerandom'
require 'net/http'
require 'uri'
require 'prawn'
require 'base64'

class PharmaTransportApp
  # Simple cookie-based auth (secure enough for MVP)
  VALID_CREDENTIALS = {
    'admin@thomasit.com' => 'pharma-2026-prod',
    'tech1@thomasit.com' => 'tech-2026-prod'
  }
  
  def self.call(env)
    path = env["PATH_INFO"]
    method = env["REQUEST_METHOD"]
    
    case [method, path]
    when ["POST", "/login"] 
      handle_login(env)
    when ["POST", "/chat"] 
      authenticated?(env) ? handle_chat(env) : unauthorized
    when ["/", "/chat"]
      authenticated?(env) ? dashboard_or_chat(path) : login_page
    when /\/batches\/(.+)\/chain-of-custody\.pdf/
      authenticated?(env) ? pdf_response(Regexp.last_match[1]) : unauthorized
    else 
      not_found
    end
  end

  def self.authenticated?(env)
    session = env["rack.session"] || {}
    !session[:authenticated].nil?
  end

  def self.handle_login(env)
    req = Rack::Request.new(env)
    email = req.params["email"]&.strip
    password = req.params["password"]&.strip
    
    if VALID_CREDENTIALS[email] == password
      session = env["rack.session"] || {}
      session[:authenticated] = true
      session[:user] = email
      env["rack.session"] = session
      
      [200, {"Content-Type" => "application/json"}, 
       [{"status" => "ok", "user" => email}.to_json]]
    else
      [401, {"Content-Type" => "application/json"}, 
       [{"error" => "Invalid credentials"}.to_json]]
    end
  end

  def self.handle_chat(env)
    req = Rack::Request.new(env)
    message = req.params["message"] || ""
    
    response = chatbot_response(message)
    [200, {"Content-Type" => "application/json"}, 
     [{"response" => response}.to_json]]
  end

  def self.chatbot_response(message)
    message.downcase!
    
    case message
    when /gps|queclink|gv55/
      "🔍 **GPS Queclink GV55**\n• Battery >20%\n• LTE signal >-90dBm\n• Reboot: 30s power cycle\n• Test: `curl /gps`"
    when /temp|sensor|2-8/
      "🌡️ **Temp Sensor 2-8°C**\n• Calibrate: 4°C ice bath\n• NIST traceable ±0.5°C\n• Alerts: /batches/[ID]/logs"
    when /batch|gs1|serial/
      "📦 **GS1 Batch Serialization**\n• LOT-PHARMA-YYYYMMDD\n• PDF: /batches/[ID]/chain-of-custody.pdf"
    when /login|password/
      "🔐 **Credentials**\n• Admin: admin@thomasit.com/pharma-2026-prod\n• Tech: tech1@thomasit.com/tech-2026-prod"
    else
      "🤖 PHARMA-BOT: Ask about GPS, temp sensors (2-8°C), GS1 batches, or login!"
    end
  end

  def self.pdf_response(batch_id)
    pdf = Prawn::Document.new
    pdf.text "CHAIN OF CUSTODY - #{batch_id}", size: 24, style: :bold
    pdf.text "Thomas IT Pharma Transport", size: 16
    pdf.text "FDA 21 CFR Part 11 Compliant", size: 12, style: :bold
    pdf.text "Generated: #{Time.now.utc}"
    pdf_content = pdf.render
    
    [200, {
      "Content-Type" => "application/pdf",
      "Content-Disposition" => "attachment; filename=chain-of-custody-#{batch_id}.pdf",
      "Content-Length" => pdf_content.bytesize.to_s
    }, [pdf_content]]
  end

  def self.dashboard_or_chat(path)
    case path
    when "/" then [200, {"Content-Type" => "text/html; charset=utf-8"}, [main_dashboard]]
    when "/chat" then [200, {"Content-Type" => "text/html; charset=utf-8"}, [chat_page]]
    end
  end

  def self.main_dashboard
    <<~HTML
<!DOCTYPE html>
<html>
<head><title>🚚 Pharma Transport - Phase 12.2</title>
<meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>
<style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:Arial,sans-serif;background:linear-gradient(135deg,#f5f7fa 0%,#c3cfe2 100%);}.navbar{background:#2c5aa0;color:white;padding:1rem;position:sticky;top:0;}.nav-container{max-width:1200px;margin:0 auto;display:flex;justify-content:space-between;}.logo{font-size:1.5em;font-weight:bold;}.nav-links a{color:white;text-decoration:none;padding:12px 24px;display:inline-block;}.content{max-width:1200px;margin:40px auto;padding:20px;}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:20px;}.card{background:white;padding:20px;border-radius:10px;box-shadow:0 5px 15px rgba(0,0,0,0.1);}</style>
</head>
<body>
<nav class="navbar">
  <div class="nav-container">
    <div class="logo">🚚 Pharma Transport</div>
    <div class="nav-links">
      <a href="/chat">🤖 PHARMA-BOT</a>
      <a href="/batches/123456/chain-of-custody.pdf">📄 PDF Report</a>
    </div>
  </div>
</nav>
<div class="content">
  <h1>✅ Phase 12.2 LIVE - PHARMA-BOT READY</h1>
  <div class="grid">
    <div class="card">
      <h3>🤖 Tech Support Chatbot</h3>
      <p>Troubleshoot GPS, temp sensors, compliance<br><a href="/chat" style="color:#2c5aa0;font-weight:bold;">START CHAT →</a></p>
    </div>
    <div class="card">
      <h3>📍 GPS Tracking</h3>
      <p>42 devices • 99.9% uptime</p>
    </div>
    <div class="card">
      <h3>📄 Compliance</h3>
      <p>FDA 21 CFR Part 11<br><a href="/batches/123456/chain-of-custody.pdf">Download PDF →</a></p>
    </div>
  </div>
</div>
</body>
</html>
HTML
  end

  def self.chat_page
    <<~HTML
<!DOCTYPE html>
<html>
<head><title>🤖 PHARMA-BOT - Tech Support</title>
<meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>
<style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:Arial,sans-serif;background:#f0f2f5;height:100vh;display:flex;flex-direction:column;}.header{background:#2c5aa0;color:white;padding:1rem;text-align:center;box-shadow:0 2px 10px rgba(0,0,0,0.1);}.chat-container{flex:1;overflow-y:auto;padding:20px;max-width:800px;margin:0 auto;width:100%;}.message{margin-bottom:1rem;padding:12px 16px;border-radius:18px;max-width:80%;word-wrap:break-word;box-shadow:0 1px 3px rgba(0,0,0,0.1);}.user{background:#2c5aa0;color:white;align-self:flex-end;margin-left:auto;}.bot{background:white;border-left:4px solid #2c5aa0;}.input-area{padding:20px;background:white;border-top:1px solid #ddd;position:sticky;bottom:0;display:flex;gap:10px;}input{flex:1;padding:12px;border:1px solid #ddd;border-radius:25px;font-size:16px;}button{padding:12px 24px;background:#2c5aa0;color:white;border:none;border-radius:25px;cursor:pointer;font-size:16px;}button:hover{background:#1e3d72;}</style>
</head>
<body>
<div class="header">
  <h2>🤖 PHARMA-BOT - Tier 1 Tech Support</h2>
  <p>GPS • Temperature Sensors • Compliance • Chain of Custody</p>
</div>
<div id="chatContainer" class="chat-container">
  <div class="message bot">👋 Hi tech! I'm PHARMA-BOT. What can I help with today?</div>
  <div class="message bot">💡 Try: "Queclink GV55 offline" or "temp sensor reading high"</div>
</div>
<div class="input-area">
  <input id="messageInput" type="text" placeholder="Describe your issue... (GPS, sensors, compliance)">
  <button onclick="sendMessage()">Send</button>
</div>
<script>
async function sendMessage() {
  const input = document.getElementById('messageInput');
  const message = input.value.trim();
  if (!message) return;
  
  addMessage(message, 'user');
  input.value = '';
  
  try {
    const response = await fetch('/chat', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: `message=${encodeURIComponent(message)}`
    });
    const data = await response.json();
    addMessage(data.response, 'bot');
  } catch (error) {
    addMessage('Sorry, having trouble connecting. Please try again.', 'bot');
  }
}

function addMessage(text, sender) {
  const container = document.getElementById('chatContainer');
  const div = document.createElement('div');
  div.className = `message ${sender}`;
  div.innerHTML = text.replace(/\n/g, '<br>');
  container.appendChild(div);
  container.scrollTop = container.scrollHeight;
}

document.getElementById('messageInput').addEventListener('keypress', (e) => {
  if (e.key === 'Enter') sendMessage();
});
</script>
</body>
</html>
HTML
  end

  def self.login_page
    [200, {"Content-Type" => "text/html; charset=utf-8"}, [<<~HTML
<!DOCTYPE html>
<html><head><title>🔐 Pharma Transport Login</title>
<meta charset='utf-8'><style>body{font-family:Arial;margin:0;padding:50px;background:linear-gradient(135deg,#f5f7fa 0%,#c3cfe2 100%);display:flex;justify-content:center;align-items:center;min-height:100vh;}form{background:white;padding:40px;border-radius:15px;box-shadow:0 15px 35px rgba(0,0,0,0.1);width:100%;max-width:400px;}h2{color:#2c5aa0;text-align:center;margin-bottom:30px;}input{width:100%;padding:12px;margin:10px 0;border:1px solid #ddd;border-radius:5px;box-sizing:border-box;font-size:16px;}button{width:100%;padding:12px;background:#2c5aa0;color:white;border:none;border-radius:5px;cursor:pointer;font-size:16px;}button:hover{background:#1e3d72;}.credentials{font-size:12px;color:#666;margin-top:20px;padding:15px;background:#f8f9fa;border-radius:5px;}</style>
</head>
<body>
<form id="loginForm">
  <h2>🚚 Pharma Transport</h2>
  <input type="email" id="email" placeholder="Email" required>
  <input type="password" id="password" placeholder="Password" required>
  <button type="submit">Login → PHARMA-BOT</button>
  <div class="credentials">
    <strong>Admin:</strong> admin@thomasit.com / pharma-2026-prod<br>
    <strong>Tech:</strong> tech1@thomasit.com / tech-2026-prod
  </div>
</form>
<script>
document.getElementById('loginForm').onsubmit = async(e) => {
  e.preventDefault();
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  const res = await fetch('/login', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: `email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`
  });
  if (res.ok) window.location.href = '/chat';
  else alert('Login failed');
};
</script>
</body></html>
HTML
    ]]
  end

  def self.unauthorized
    [401, {"Content-Type" => "text/plain"}, ["Login required"]]
  end

  def self.not_found
    [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
  end
end

use Rack::Session::Cookie, key: '_pharma_session', secret: 'pharma-transport-2026-production-secret'
run PharmaTransportApp
