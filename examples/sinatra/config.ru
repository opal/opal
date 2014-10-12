require 'opal'
require 'sinatra'

opal = Opal::Server.new {|s|
  s.append_path 'app'
  s.main = 'application'
}

map opal.source_maps.prefix do
  run opal.source_maps
end

map '/assets' do
  run opal.sprockets
end

get '/' do
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <script src="/assets/application.js"></script>
      </head>
    </html>
  HTML
end

run Sinatra::Application
