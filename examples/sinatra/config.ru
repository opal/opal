require 'opal'
require 'sinatra'

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

map '/assets' do
  env = Opal::Environment.new
  env.append_path 'app'
  run env
end

run Sinatra::Application
