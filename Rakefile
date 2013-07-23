require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

require 'rack'
require 'webrick'
require 'opal-sprockets'

class RunSpec
  def initialize(file=nil)
    Opal::Processor.arity_check_enabled = true

    ENV['OPAL_SPEC'] = file.nil? ? ["#{Dir.pwd}/spec/"].join(',') : file.join(',')

    build_specs

    server = fork do
      app = Rack::Builder.app do
        use Rack::ShowExceptions
        run Rack::Directory.new('.')
      end

      Rack::Server.start(:app => app, :Port => 9999, :AccessLog => [],
        :Logger => WEBrick::Log.new("/dev/null"))
    end

    system "phantomjs \"spec/ospec/sprockets.js\" \"http://localhost:9999/spec/index.html\""
    success = $?.success?

    exit 1 unless success

  rescue => e
    puts e.message
  ensure
    Process.kill(:SIGINT, server)
    Process.wait
  end

  def build_specs
    env = Opal::Environment.new
    env.append_path 'spec'
    env.use_gem 'mspec'

    FileUtils.mkdir_p 'build'
    puts " * build/specs.js"

    specs = uglify(env['ospec/main'].to_s)
    File.open('build/specs.js', 'w+') { |o| o << specs }
  end

  # Only if OPAL_UGLIFY is set
  def uglify(str)
    if ENV['OPAL_UGLIFY']
      require 'uglifier'
      puts " * uglifying"
      Uglifier.compile(str)
    else
      str
    end
  end
end

desc "Run tests through mspec"
task :default do
  RunSpec.new
end

desc "Build specs to build/specs.js and build/specs.min.js"
task :build_specs do
  require 'uglifier'

  Opal::Processor.arity_check_enabled = true
  ENV['OPAL_SPEC'] = ["#{Dir.pwd}/spec/"].join(',')

  env = Opal::Environment.new
  env.append_path 'spec'
  env.use_gem 'mspec'

  FileUtils.mkdir_p 'build'

  puts " * build/specs.js"
  specs = env['ospec/main'].to_s

  puts " * build/specs.min.js"
#  min = Uglifier.compile(specs)

  File.open('build/specs.js', 'w+') { |o| o << specs }
#  File.open('build/specs.min.js', 'w+') { |o| o << min }
end

desc "Run task with spec:dir:file helper"
namespace :spec do
  task 'dirs' do
  end
  rule '' do |task|

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
      raise ArgumentError, "File or Dir with task #{dirs.join('/')} not found." if path.empty?
      path
    end

    RunSpec.new(path(task.name.split(":")))
  end
end

desc "Build opal.js and opal-parser.js to build/"
task :dist do
  Opal::Processor.arity_check_enabled = false
  Opal::Processor.source_map_enabled = false
  Opal::Processor.method_missing_enabled = false

  env = Opal::Environment.new

  Dir.mkdir 'build' unless File.directory? 'build'

  #%w[opal opal-parser].each do |lib|
  ['opal'].each do |lib|
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

desc "Rebuild grammar.rb for opal parser"
task :racc do
  %x(racc -l lib/opal/grammar.y -o lib/opal/grammar.rb)
end

# Used for uglifying source to minify
def uglify(str)
  IO.popen('uglifyjs', 'r+') do |i|
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
