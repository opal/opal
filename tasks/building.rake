require 'opal/version'

desc <<-DESC
Build *corelib* and *stdlib* to "build/"

You can restrict the file list with the FILES env var (comma separated)
and the destination dir with the DIR env var.

Example: rake dist DIR=/tmp/foo FILES='opal.rb,base64.rb'
Example: rake dist DIR=cdn/opal/#{Opal::VERSION}
Example: rake dist DIR=cdn/opal/master
DESC
task :dist do
  require 'opal/util'
  require 'opal/config'

  Opal::Config.arity_check_enabled = false
  Opal::Config.const_missing_enabled = false
  Opal::Config.dynamic_require_severity = :warning
  Opal::Config.missing_require_severity = :error

  # Hike gem is required to build opal-builder
  Opal.use_gem 'hike'

  build_dir = ENV['DIR'] || 'build'
  files     = ENV['FILES'] ? ENV['FILES'].split(',') :
              Dir['{opal,stdlib}/*.rb'].map { |lib| File.basename(lib, '.rb') }

  mkdir_p build_dir unless File.directory? build_dir
  width = files.map(&:size).max

  files.map do |lib|
    Thread.new {
      log = ''
      log << "* building #{lib}...".ljust(width+'* building ... '.size)
      $stdout.flush

      # Set requirable to true to be consistent with previous builds, generated
      # with sprockets.
      src = Opal::Builder.build(lib, requirable: true).to_s
      min = Opal::Util.uglify src
      gzp = Opal::Util.gzip min

      File.open("#{build_dir}/#{lib}.js", 'w+')        { |f| f << src }
      File.open("#{build_dir}/#{lib}.min.js", 'w+')    { |f| f << min } if min
      File.open("#{build_dir}/#{lib}.min.js.gz", 'w+') { |f| f << gzp } if gzp

      log << "done. ("
      log << "development: #{('%.2f' % (src.size/1000.0)).rjust(7)}KB"
      log <<  ", minified: #{('%.2f' % (min.size/1000.0)).rjust(7)}KB" if min
      log <<   ", gzipped: #{('%.2f' % (gzp.size/1000.0)).rjust(7)}KB" if gzp
      log << ")."
      log
    }
  end.map(&:value).map(&method(:puts))
end

desc 'Rebuild grammar.rb for opal parser'
task :racc do
  debug_option = '--debug' if ENV['RACC_DEBUG']
  sh "racc #{debug_option} -l -o lib/opal/parser/grammar.rb lib/opal/parser/grammar.y"
end

desc 'Remove any generated file.'
task :clobber do
  rm_r './build'
end

