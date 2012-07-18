require 'rack'

app = lambda do |env|
  path = env['PATH_INFO']
  base_path = File.expand_path('../test/index.html', __FILE__)
  case path
  when /\.js/
    contents = File.read(File.join(File.dirname(base_path), '..', path))
    [200, {'Content-Type' => 'application/x-javascript'}, [contents]]
  else
    system 'rake opal'
    contents = File.read(base_path)
    [200, {'Content-Type' => 'text/html'}, [contents]]
  end 
end

run app
