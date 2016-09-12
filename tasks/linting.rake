desc "Build *corelib* and *stdlib* and lint the result"
task :jshint do
  dir = 'tmp/lint'

  unless ENV['SKIP_BUILD']
    rm_rf dir if File.exist? dir
    sh "rake dist DIR=#{dir}"
  end

  Dir["#{dir}/*.js"].each {|path|
    # opal-builder and opal-parser take so long travis stalls
    next if path =~ /.min.js\z|opal-builder|opal-parser/

    sh "jshint --verbose #{path}"
  }
end
