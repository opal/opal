require 'opal'
require 'sinatra'

opal = Opal::Server.new {|s|
  s.append_path 'app'
  s.main = 'application'
}

sprockets   = opal.sprockets
prefix      = '/assets'
maps_prefix = '/__OPAL_SOURCE_MAPS__'
maps_app    = Opal::SourceMapServer.new(sprockets, maps_prefix)

# Monkeypatch sourcemap header support into sprockets
::Opal::Sprockets::SourceMapHeaderPatch.inject!(maps_prefix)

map maps_prefix do
  run maps_app
end

map prefix do
  run sprockets
end

get '/' do
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8">
        #{::Opal::Sprockets.javascript_include_tag('application', sprockets: sprockets, prefix: prefix, debug: true)}
      </head>
    </html>
  HTML
end

run Sinatra::Application
