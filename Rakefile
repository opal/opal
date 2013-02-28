require 'bundler'
Bundler.require

desc "Run tests"
task :default do
  require 'rack'
  require 'webrick'

  Opal::Processor.arity_check_enabled = true

  server = fork do
    s = Opal::Server.new { |s|
      s.append_path 'spec'
      s.debug = false
      s.main = 'ospec/autorun'
    }

    Rack::Server.start(:app => s, :Port => 9999, :AccessLog => [],
      :Logger => WEBrick::Log.new("/dev/null"))
  end

  system "phantomjs \"spec/sprockets_runner.js\" \"http://localhost:9999/\""
  success = $?.success?

  Process.kill(:SIGINT, server)
  Process.wait

  exit 1 unless success
end

desc "Check file sizes for opal.js runtime"
task :sizes do
  env = Sprockets::Environment.new
  Opal.paths.each { |p| env.append_path p }

  src = env['opal'].to_s
  min = uglify src
  gzp = gzip min

  puts "development: #{src.size}, minified: #{min.size}, gzipped: #{gzp.size}"
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
