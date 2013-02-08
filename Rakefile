require 'bundler/setup'
require 'opal-spec'

desc "Build specs ready to run"
task :build_specs => [:dir] do
  Opal.append_path File.join(File.dirname(__FILE__), 'spec')

  File.open('build/specs.js', 'w+') { |o| o.puts Opal.process('autorun') }
end

desc "Run opal specs through phantomjs"
task :test do
  OpalSpec.runner
end

task :default => [:build_specs, :test]

task :dir do
  require 'fileutils'
  FileUtils.mkdir_p 'build'
end

desc "Check file sizes for opal.js runtime"
task :sizes do
  o = Opal.process('opal')
  m = uglify o
  g = gzip m

  puts "development: #{o.size}, minified: #{m.size}, gzipped: #{g.size}"
end

desc "Rebuild grammar.rb for opal parser"
task :racc do
  %x(racc -l lib/opal/grammar.y -o lib/opal/grammar.rb)
end

# Used for uglifying source to minify
def uglify(str)
  IO.popen('uglifyjs -nc', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end

# Gzip code to check file size
def gzip(str)
  IO.popen('gzip -f', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end
