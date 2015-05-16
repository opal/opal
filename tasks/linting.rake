directory 'tmp/lint'

desc "Build *corelib* and *stdlib* and lint the result"
task :lint => 'tmp/lint' do
  require 'opal/sprockets/environment'

  env = Opal::Environment.new

  files = Dir['{opal,stdlib}/*.rb'].map { |lib| File.basename(lib, '.rb') }

  files.each do |lib|
    next if lib == 'minitest'
    File.binwrite("tmp/lint/#{lib}.js", env[lib].to_s)
  end

  sh "jshint --verbose tmp/lint/*.js"
end

