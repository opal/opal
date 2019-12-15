import 'tasks/building.rake'
desc "Build *corelib* and *stdlib* and lint the result"
task :jshint do
  dir = 'tmp/lint'
  puts
  puts "= Checking distributed files..."
  unless ENV['SKIP_BUILD']
    rm_rf dir if File.exist? dir
    ENV['DIR'] = dir
    Rake::Task[:dist].invoke
  end

  Dir["#{dir}/*.js"].each {|path|
    # opal-builder and opal-parser take so long travis stalls
    next if path =~ /.min.js\z|opal-builder|opal-parser/

    sh "jshint --verbose #{path}"
  }
  puts
  puts "= Checking corelib files separately..."
  js_paths = []
  Dir['opal/{opal,corelib}/*.rb'].each do |path|
    js_path = "#{dir}/#{path.tr('/', '-')}.js"
    Bundler::SharedHelpers.set_bundle_environment
    File.write js_path, Opal.compile(File.read(path), file: path, dynamic_require_severity: :ignore)
    js_paths << js_path
  end
  js_paths.each do |js_path|
    sh "jshint --verbose #{js_path}"
  end
  sh "jshint --verbose opal/corelib/runtime.js"
end

begin
  require 'rubocop/rake_task'
  desc 'Run RuboCop on lib/, opal/ and stdlib/ directories'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options << '--extra-details'
    task.options << '--display-style-guide'
    task.options << '--parallel'
  end
rescue LoadError
  # Not available on Windows
end

task :lint => [:jshint, :rubocop]
