class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true

  def health
    render plain: "Pharma Transport Rails 7.1 - LIVE ✅", status: 200
  end
end
