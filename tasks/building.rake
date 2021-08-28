require 'opal/version'

desc <<-DESC
Build *corelib* and *stdlib* to "build/"

You can restrict the file list with the FILES env var (comma separated)
and the destination dir with the DIR env var, FORMATS to select output formats.

Example: rake dist DIR=/tmp/foo FILES='opal.rb,base64.rb'
Example: rake dist DIR=cdn/opal/#{Opal::VERSION}
Example: rake dist DIR=cdn/opal/master
Example: rake dist DIR=cdn/opal/master FORMATS=js,min,gz
Example: rake dist DIR=cdn/opal/master FORMATS=js,map
DESC
task :dist do
  require 'opal/util'
  require 'opal/config'

  Opal::Config.arity_check_enabled = false
  Opal::Config.const_missing_enabled = false
  Opal::Config.dynamic_require_severity = :warning
  Opal::Config.missing_require_severity = :error

  build_dir = ENV['DIR'] || 'build'
  files     = ENV['FILES'] ? ENV['FILES'].split(',') :
              Dir['{opal,stdlib}/*.rb'].map { |lib| File.basename(lib, '.rb') }
  formats = (ENV['FORMATS'] || 'js,min,gz').split(',')

  mkdir_p build_dir unless File.directory? build_dir
  width = files.map(&:size).max

  files.map do |lib|
    Thread.new {
      log = ''
      log << "* building #{lib}...".ljust(width+'* building ... '.size)
      $stdout.flush

      # Set requirable to true, unless building opal. This allows opal to be auto-loaded.
      requirable = (lib != 'opal')
      builder = Opal::Builder.build(lib, requirable: requirable)

      src = builder.to_s if (formats & %w[js min gz]).any?
      src << ";" << builder.source_map.to_data_uri_comment if (formats & %w[map]).any?
      min = Opal::Util.uglify src if (formats & %w[min gz]).any?
      gzp = Opal::Util.gzip min if (formats & %w[gz]).any?

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

desc 'Remove any generated file.'
task :clobber do
  rm_r './build'
end

