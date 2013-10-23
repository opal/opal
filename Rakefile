require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

namespace :github do
  task :upload_assets do
    require 'octokit'
    # https://github.com/octokit/octokit.rb#oauth-access-tokens
    token_path = '.github_access_token'
    File.exist?(token_path) or raise ArgumentError, "Please create a personal access token (https://github.com/settings/tokens/new) and paste it inside #{token_path.inspect}"
    token = File.read(token_path).strip
    client = Octokit::Client.new :access_token => token
    tag_name = ENV['TAG'] || raise(ArgumentError, 'missing the TAG env variable (e.g. TAG=v0.4.4)')
    release = client.releases('opal/opal').find{|r| p(r.id); p(r).tag_name == tag_name}
    release_url = "https://api.github.com/repos/opal/opal/releases/#{release.id}"
    %w[opal opal-parser].each do |name|
      client.upload_asset release_url, "build/#{name}.js", :content_type => 'application/x-javascript'
      client.upload_asset release_url, "build/#{name}.min.js", :content_type => 'application/x-javascript'
      client.upload_asset release_url, "build/#{name}.min.js.gz", :content_type => 'application/octet-stream'
    end
  end
end

require 'rack'
require 'webrick'
require 'opal-sprockets'

# mspec/rubyspec use a top level "language_version" to require relative specs.
# We can't do this at runtime, so we hijack the method (and make sure we only
# do this at the top level). We figure out which file we are including, and
# add it to our require list
class ::Opal::Parser
  alias_method :mspec_handle_call, :handle_call

  def handle_call(sexp)
    if sexp[2] == :language_version and @scope.top?
      lang_type = sexp[3][2][1]
      target = "rubyspec/language/versions/#{lang_type}_1.9"

      if File.exist?(target)
        @requires << target
      end

      return fragment("nil")
    end

    mspec_handle_call sexp
  end
end

class SpecEnvironment < Opal::Environment
  def initialize
    super
    append_path 'spec'
    append_path 'rubyspec'
    use_gem 'mspec'
  end

  def specs
    @specs ||= self['ospec/main'].to_s
  end

  def build_min file = 'build/specs.min.js'
    require 'uglifier'
    build Uglifier.compile(specs), file
  end

  def build code = specs, file = 'build/specs.js'
    FileUtils.mkdir_p File.dirname(file)
    puts "Building #{file}..."
    File.open(file, 'w+') { |o| o << code }
  end
end

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
    SpecEnvironment.new.build
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

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:mri_spec) do |t|
  t.pattern = 'mri_spec/**/*_spec.rb'
end

desc "Run tests through mspec"
task :mspec do
  RunSpec.new
end

task :default => [:mri_spec, :mspec] do
end

desc "Build specs to build/specs.js and build/specs.min.js"
task :build_specs do
  Opal::Processor.arity_check_enabled = true
  ENV['OPAL_SPEC'] = ["#{Dir.pwd}/spec/"].join(',')

  env = SpecEnvironment.new
  env.build
end

desc <<-DESC
Run task with spec:dir:file helper
Example: to run all antive specs in /spec/opal/native
type:
  rake spec:opal:native
DESC
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
  Opal::Processor.const_missing_enabled = false

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
