# FIXME: there must be a better way
Encoding.default_external = 'utf-8'

require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

import 'tasks/github.rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/cli/**/*_spec.rb'
end

require 'mspec/opal/rake_task'
MSpec::Opal::RakeTask.new(:mspec) do |config|
  config.pattern = ENV['MSPEC_PATTERN'] if ENV['MSPEC_PATTERN']
  config.basedir = ENV['MSPEC_BASEDIR'] if ENV['MSPEC_BASEDIR']
end

task :default => [:rspec, :mspec]


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

  Opal::Processor.arity_check_enabled = false
  Opal::Processor.const_missing_enabled = false
  env = Opal::Environment.new

  build_dir = ENV['DIR'] || 'build'
  files     = ENV['FILES'] ? ENV['FILES'].split(',') :
              Dir['{opal,stdlib}/*.rb'].map { |lib| File.basename(lib, '.rb') }

  Dir.mkdir build_dir unless File.directory? build_dir
  width = files.map(&:size).max

  files.each do |lib|
    print "* building #{lib}...".ljust(width+'* building ... '.size)
    $stdout.flush

    src = env[lib].to_s
    min = Opal::Util.uglify src
    gzp = Opal::Util.gzip min

    File.open("#{build_dir}/#{lib}.js", 'w+')        { |f| f << src }
    File.open("#{build_dir}/#{lib}.min.js", 'w+')    { |f| f << min } if min
    File.open("#{build_dir}/#{lib}.min.js.gz", 'w+') { |f| f << gzp } if gzp

    print "done. ("
    print "development: #{('%.2f' % (src.size/1000.0)).rjust(6)}KB"
    print  ", minified: #{('%.2f' % (min.size/1000.0)).rjust(6)}KB" if min
    print   ", gzipped: #{('%.2f' % (gzp.size/1000.0)).rjust(6)}KB" if gzp
    puts  ")."
  end
end

desc 'Rebuild grammar.rb for opal parser'
task :racc do
  %x(racc -l lib/opal/parser/grammar.y -o lib/opal/parser/grammar.rb)
end

desc 'Remove any generated file.'
task :clobber do
  rm_r './build'
end
