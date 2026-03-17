# Update src/config.ru
require 'rack'

class PharmaTransportApp
  def self.call(env)
    path = env['PATH_INFO']
    
    case path
    when '/'
      [200, {"Content-Type" => "text/html"}, 
       ["<h1>🚀 Pharma Transport Dashboard LIVE</h1>..."]]
    when %r{/batches/\d+/chain-of-custody\.pdf$}
      # Serve your PDF files here
      [200, {"Content-Type" => "application/pdf"}, 
       [File.read("pdfs/#{path.split('/').last}", mode: 'rb')]]
    else
      [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
    end
  end
end

run PharmaTransportApp
