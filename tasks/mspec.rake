require 'rack'
require 'webrick'
require 'opal-sprockets'

class Opal::Nodes::CallNode
  # Rubyspec uses this call to load in language specific features at runtime.
  # We can't do this at runtime, so handle it during compilation
  add_special :language_version do
    if meth == :language_version and scope.top?
      lang_type = arglist[2][1]
      target = "rubyspec/language/versions/#{lang_type}_1.9"

      if File.exist?(target)
        compiler.requires << target
      end

      return fragment("nil")
    end

    nil
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
    build uglify(specs), file
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

    ENV['OPAL_SPEC'] = self.specs_to_run(file).join(',')

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

  def specs_to_run(file=nil)
    specs = []

    # add any filters in spec/filters of specs we dont want to run
    specs << Dir.glob('spec/filters/**/*.rb').map { |s| s.sub(/^spec\//, '').sub(/\.rb$/, '') }

    # add custom opal specs from spec/
    specs << (file.nil? ? Dir.glob("#{Dir.pwd}/spec/**/*_spec.{rb,opal}") : file)

    # add any rubyspecs we want to run (defined in spec/rubyspecs)
    specs.push File.read('spec/rubyspecs').split("\n").reject(&:empty?)

    specs.flatten
  end

  def build_specs
    SpecEnvironment.new.build
  end
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
