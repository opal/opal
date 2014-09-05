require 'opal'
require 'sinatra'

opal = Opal::Server.new {|s|
  s.append_path 'app'
  s.main = 'application'
}

map '/__opal_source_maps__' do
  run opal.source_maps
end

map '/assets' do
  run opal.sprockets
end

get '/' do
  <<-EOS
    <!doctype html>
    <html>
      <head>
        <script src="/assets/application.js"></script>
      </head>
    </html>
  EOS
end

run Sinatra::Application
