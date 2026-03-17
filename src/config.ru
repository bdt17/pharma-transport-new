require 'rack'

class PharmaTransportApp
  def self.call(env)
    [200, {"Content-Type" => "text/html"}, ["Pharma Transport Dashboard - Deployed!"]]
  end
end

run PharmaTransportApp
