class PagesController < ApplicationController
  def index
    render layout: false  # ← ADD THIS LINE
  end
end
