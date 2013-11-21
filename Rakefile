require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

import 'tasks/github.rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/cli/**/*_spec.rb'
end

require 'mspec/opal/rake_task'
MSpec::Opal::RakeTask.new(:mspec)

task :default => [:rspec, :mspec]


desc 'Build opal.js and opal-parser.js to build/'
task :dist do
  Opal::Processor.arity_check_enabled = false
  Opal::Processor.const_missing_enabled = false

  env = Opal::Environment.new

  Dir.mkdir 'build' unless File.directory? 'build'
  libs = Dir['{opal,stdlib}/*.rb'].map { |lib| File.basename(lib, '.rb') }
  width = libs.map(&:size).max

  libs.each do |lib|
    print "* building #{lib}...".ljust(width+'* building ... '.size)
    $stdout.flush

    src = env[lib].to_s
    min = Opal::Builder::Util.uglify src
    gzp = Opal::Builder::Util.gzip min

    File.open("build/#{lib}.js", 'w+')        { |f| f << src }
    File.open("build/#{lib}.min.js", 'w+')    { |f| f << min } if min
    File.open("build/#{lib}.min.js.gz", 'w+') { |f| f << gzp } if gzp

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
