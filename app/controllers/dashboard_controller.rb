class DashboardController < ApplicationController
  def index
    render html: '<div style="max-width:1200px;margin:0 auto;padding:40px"><h1>📊 Pharma Dashboard</h1><p>Batches, GPS trucks, 21 CFR compliance → Login to activate</p><a href="/users/sign_in" style="background:blue;color:white;padding:12px 24px;border-radius:8px">Login</a></div>'.html_safe
  end
end
