require 'bundler'
Bundler.require

require 'rack'
require 'webrick'

class RunSpec
  def initialize(file=nil)
    Opal::Processor.arity_check_enabled = true

    ENV['OPAL_SPEC'] = file.nil? ? ["#{Dir.pwd}/spec/"].join(',') : file.join(',')

    server = fork do
      serv = Opal::Server.new { |s|
        s.append_path 'spec' # before mspec, so we use our overrides
        s.use_gem 'mspec'
        s.debug = false
        s.main = 'ospec/main'
      }

      Rack::Server.start(:app => serv, :Port => 9999, :AccessLog => [],
        :Logger => WEBrick::Log.new("/dev/null"))
    end

    system "phantomjs \"spec/ospec/sprockets.js\" \"http://localhost:9999/\""
    success = $?.success?

    exit 1 unless success

  ensure
    Process.kill(:SIGINT, server)
    Process.wait
  end
end

desc "Run tests through mspec"
task :default do
  RunSpec.new
end

desc "Run task with spec:dir:file helper"
namespace :spec do
  task 'dirs' do
  end
  rule '' do |t|

    #build path for spec files\dirs.
    #Example:
    #spec:core => spec/core/
    #spec:core:array:allocate => spec/core/array/allocate_spec.rb
    def path(dirs)
      path = "#{Dir.pwd}"
      dirs.each do |dir|
        base = path + "/#{dir}"
        if Dir.exists?(base)
          path = base
        else
          path = Dir.glob("#{base}_spec.rb")
        end
      end
      path = [path].flatten
      raise "File or Dir with task #{t.name} not found." if path.empty?
      path
    end

    RunSpec.new(path(t.name.split(":")))
  end
end

desc "Build opal.js and opal-parser.js to build/"
task :dist do
  Opal::Processor.arity_check_enabled = false

  env = Opal::Environment.new

  Dir.mkdir 'build' unless File.directory? 'build'

  %w[opal opal-parser].each do |lib|
    puts "* building #{lib}..."

    src = env[lib].to_s
    min = uglify src
    gzp = gzip min

    File.open("build/#{lib}.js", 'w+')        { |f| f << src }
    File.open("build/#{lib}.min.js", 'w+')    { |f| f << min } if min
    File.open("build/#{lib}.min.js.gz", 'w+') { |f| f << gzp } if gzp

    print "done. (development: #{src.size}B"
    print ", minified: #{min.size}B" if min
    print ", gzipped: #{gzp.size}Bx"  if gzp
    puts  ")."
    puts
  end
end

desc "Check file sizes for opal.js runtime"
task :sizes => :dist do
end

desc "Rebuild grammar.rb for opal parser"
task :racc do
  %x(racc -l lib/opal/grammar.y -o lib/opal/grammar.rb)
end

# Used for uglifying source to minify
def uglify(str)
  IO.popen('uglifyjs --no-mangle --compress warnings=false', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
rescue Errno::ENOENT
  $stderr.puts '"uglifyjs" command not found (install with: "npm install -g uglify-js")'
  nil
end

# Gzip code to check file size
def gzip(str)
  IO.popen('gzip -f', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
rescue Errno::ENOENT
  $stderr.puts '"gzip" command not found, it is required to produce the .gz version'
  nil
end
