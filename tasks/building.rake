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

  # Hike gem is required to build opal-builder
  Opal.use_gem 'hike'

  build_dir = ENV['DIR'] || 'build'
  files     = ENV['FILES'] ? ENV['FILES'].split(',') :
              Dir['{opal,stdlib}/*.rb'].map { |lib| File.basename(lib, '.rb') }

  Dir.mkdir build_dir unless File.directory? build_dir
  width = files.map(&:size).max

  files.each do |lib|
    print "* building #{lib}...".ljust(width+'* building ... '.size)
    $stdout.flush

    src = Opal::Builder.build(lib).to_s
    min = Opal::Util.uglify src
    gzp = Opal::Util.gzip min

    File.open("#{build_dir}/#{lib}.js", 'w+')        { |f| f << src }
    File.open("#{build_dir}/#{lib}.min.js", 'w+')    { |f| f << min } if min
    File.open("#{build_dir}/#{lib}.min.js.gz", 'w+') { |f| f << gzp } if gzp

    print "done. ("
    print "development: #{('%.2f' % (src.size/1000.0)).rjust(7)}KB"
    print  ", minified: #{('%.2f' % (min.size/1000.0)).rjust(7)}KB" if min
    print   ", gzipped: #{('%.2f' % (gzp.size/1000.0)).rjust(7)}KB" if gzp
    puts  ")."
  end
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

