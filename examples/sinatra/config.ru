require 'opal'
require 'sinatra'

opal = Opal::Server.new {|s|
  s.append_path 'app'
  s.main = 'application'
}

sprockets   = opal.sprockets
maps_prefix = '/__OPAL_SOURCE_MAPS__'
maps_app    = Opal::SourceMapServer.new(sprockets, maps_prefix)

# Monkeypatch sourcemap header support into sprockets
::Opal::Sprockets::SourceMapHeaderPatch.inject!(maps_prefix)

map maps_prefix do
  run maps_app
end

map '/assets' do
  run sprockets
end

get '/' do
  opal_boot_code = Opal::Processor.load_asset_code(sprockets, 'application')

  <<-HTML
    <!doctype html>
    <html>
      <head>
        <script src="/assets/application.js"></script>
        <script>#{opal_boot_code}</script>
      </head>
    </html>
  HTML
end

run Sinatra::Application
