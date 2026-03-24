Rails.application.routes.draw do
  root to: proc { |env|
    [
      200,
      {
        "Content-Type" => "text/html",
        "Cache-Control" => "public, max-age=300"
      },
      [<<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Thomas IT | Pharma Transport SaaS</title>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
          <style>
            * { margin:0; padding:0; box-sizing:border-box; }
            body { 
              font-family: 'Inter', sans-serif; 
              background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
              color: #1e293b; min-height:100vh;
            }
            .container { max-width:1400px; margin:0 auto; padding:24px; }
            .header { 
              display:flex; justify-content:space-between; align-items:center; 
              margin-bottom:40px; padding-bottom:24px; border-bottom:1px solid #e2e8f0;
            }
            .logo { font-size:28px; font-weight:700; color:#1e40af; }
            .header-nav { display:flex; gap:24px; }
            .nav-link { color:#475569; text-decoration:none; font-weight:500; }
            .nav-link.active { color:#1e40af; }
            .stats-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:24px; margin-bottom:48px; }
            .stat-card { 
              background:#fff; padding:24px; border-radius:12px; box-shadow:0 4px 6px rgba(0,0,0,0.05);
              border-left:4px solid #1e40af; text-align:center;
            }
            .stat-number { font-size:32px; font-weight:700; color:#1e40af; }
            .stat-label { color:#64748b; font-size:14px; margin-top:4px; }
            .main-grid { display:grid; grid-template-columns:1fr 400px; gap:32px; }
            @media (max-width:1024px) { .main-grid { grid-template-columns:1fr; } }
            .content-card { background:#fff; padding:32px; border-radius:12px; box-shadow:0 4px 6px rgba(0,0,0,0.05); }
            .card-title { font-size:24px; font-weight:600; margin-bottom:24px; color:#1e293b; }
            .btn { 
              padding:12px 24px; background:#1e40af; color:white; 
              border:none; border-radius:8px; font-weight:500; cursor:pointer;
              text-decoration:none; display:inline-block; margin:4px;
            }
            .btn-secondary { background:#f1f5f9; color:#1e293b; }
            .demo-section { 
              background:#fff; padding:48px 32px; border-radius:16px; 
              box-shadow:0 10px 25px rgba(0,0,0,0.1); text-align:center; margin-top:48px;
            }
            .demo-inputs { display:flex; gap:16px; justify-content:center; flex-wrap:wrap; margin:32px 0; }
            .demo-input { padding:16px; border:2px solid #e2e8f0; border-radius:8px; font-size:16px; width:280px; }
          </style>
        </head>
        <body>
          <div class="container">
            <header class="header">
              <div class="logo">Thomas IT</div>
              <nav class="header-nav">
                <a href="#" class="nav-link active">Dashboard</a>
                <a href="#" class="nav-link">Batches</a>
                <a href="#" class="nav-link">Carriers</a>
                <a href="#" class="nav-link">Compliance</a>
              </nav>
            </header>

            <div class="stats-grid">
              <div class="stat-card">
                <div class="stat-number">247</div>
                <div class="stat-label">Active Batches</div>
              </div>
              <div class="stat-card">
                <div class="stat-number">99.7%</div>
                <div class="stat-label">Cold Chain SLA</div>
              </div>
              <div class="stat-card">
                <div class="stat-number">14</div>
                <div class="stat-label">Carriers</div>
              </div>
              <div class="stat-card">
                <div class="stat-number">✓ Compliant</div>
                <div class="stat-label">21 CFR Part 11</div>
              </div>
            </div>

            <div class="main-grid">
              <div class="content-card">
                <h2 class="card-title">Live Batches</h2>
                <div style="display:grid; gap:16px; margin-bottom:24px;">
                  <div style="display:flex; justify-content:space-between; padding:16px; background:#f8fafc; border-radius:8px;">
                    <span>PHX-DEN-001</span>
                    <span style="color:#059669;">2-8°C ✓</span>
                  </div>
                  <div style="display:flex; justify-content:space-between; padding:16px; background:#f8fafc; border-radius:8px;">
                    <span>PHX-LAX-042</span>
                    <span style="color:#dc2626;">Alert 4.2°C</span>
                  </div>
                </div>
                <a href="/batches" class="btn">View All Batches</a>
                <a href="#" class="btn btn-secondary">Download CoF PDF</a>
              </div>

              <div class="content-card">
                <h2 class="card-title">Quick Actions</h2>
                <a href="#" class="btn" style="width:100%; margin-bottom:12px;">Stripe Payments</a>
                <a href="https://network-swap-rackup.onrender.com" target="_blank" class="btn" style="width:100%;">GPS Tracking</a>
                <a href="#" class="btn btn-secondary" style="width:100%;">New Batch</a>
              </div>
            </div>

            <div class="demo-section">
              <h2 style="color:#1e293b; margin-bottom:16px;">Pharma Logistics Demo</h2>
              <p style="color:#64748b; max-width:600px; margin:0 auto 32px;">Track pharma logistics with 21 CFR Part 11 compliance</p>
              <div class="demo-inputs">
                <input class="demo-input" placeholder="Enter batch ID (ex: PHX-DEN-001)">
                <button class="btn">Track Batch</button>
              </div>
              <div style="background:#f8fafc; padding:24px; border-radius:12px; max-width:600px; margin:0 auto;">
                <div style="font-weight:500;">Status: <span style="color:#059669;">In Transit</span></div>
                <div>Temp: 3.2°C | ETA: 14:32 | Carrier: PHX Drone Logistics</div>
              </div>
            </div>
          </div>
        </body>
        </html>
      HTML
      ]
    }
  }

  # Placeholder routes
  get "/batches", to: proc { [200, {"Content-Type" => "text/plain"}, ["Batches page coming soon..."]] }
  get "/health", to: proc { [{ok: true, service: "pharma-transport", ts: Time.now.utc.iso8601}.to_json] }
end
