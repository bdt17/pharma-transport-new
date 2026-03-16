# Puma = Render production server (no rackup issues)
require 'puma'
require './pharma_transport.ru'

run PharmaTransportApp
