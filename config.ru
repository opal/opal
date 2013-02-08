require 'bundler'
Bundler.require

html = <<HTML
  <!DOCTYPE html>
  <html>
  <head>
    <title>Opal corelib and runtime specs</title>
  </head>
    <body>
      <script type="text/javascript" src="/assets/autorun.js"></script>
    </body>
  </html>
HTML

map '/assets' do
  env = Opal::Environment.new
  env.append_path 'spec'
  run env
end

map '/' do
  run lambda { |env|
    [200, {'Content-Type' => 'text/html'}, [html]]
  }
end
