require 'rubocop/rake_task'

desc "Build *corelib* and *stdlib* and lint the result"
task :jshint do
  dir = 'tmp/lint'
  puts
  puts "= Checking distributed files..."
  unless ENV['SKIP_BUILD']
    rm_rf dir if File.exist? dir
    sh "bundle exec rake dist DIR=#{dir}"
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
    sh "bundle exec opal -Dignore -cEO #{path} > #{js_path}"
    js_paths << js_path
  end
  js_paths.each do |js_path|
    sh "jshint --verbose #{js_path}"
  end
  sh "jshint --verbose opal/corelib/runtime.js"
end

desc 'Run RuboCop on lib/ and opal/ directories'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options << '--fail-fast'
end
