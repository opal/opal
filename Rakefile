require 'bundler'
Bundler.require

desc "Run opal specs through phantomjs"
task :test do
  require 'rack'
  require 'webrick'

  server = fork do
    Rack::Server.start(:config => 'config.ru', :Port => 9999,
      :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
  end

  system "phantomjs vendor/runner.js \"http://localhost:9999/\""

  success = $?.success?
  Process.kill(:SIGINT, server)
  Process.wait

  exit(1) unless success
end

task :default => :test

desc "Check file sizes for opal.js runtime"
task :sizes do
  o = Opal::Environment.new['opal'].to_s
  m = uglify o
  g = gzip m

  puts "development: #{o.size}, minified: #{m.size}, gzipped: #{g.size}"
end

desc "Rebuild grammar.rb for opal parser"
task :racc do
  %x(racc -l lib/opal/grammar.y -o lib/opal/grammar.rb)
end

# Used for uglifying source to minify
def uglify(str)
  IO.popen('uglifyjs -nc', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end

# Gzip code to check file size
def gzip(str)
  IO.popen('gzip -f', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end
