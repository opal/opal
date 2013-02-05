require 'bundler/setup'
require 'opal-spec'

desc "Build opal.js into ./build"
task :opal => [:dir] do
  File.open('build/opal.js', 'w+') { |o| o.puts Opal.process('opal') }
end

desc "Build opal-parser.js into ./build"
task :parser => [:dir] do
  File.open('build/opal-parser.js', 'w+') { |o| o.puts Opal.process('opal-parser') }
end

desc "Build specs ready to run"
task :build_specs => [:dir] do
  Opal.append_path File.join(File.dirname(__FILE__), 'spec')

  File.open('build/core_spec.js', 'w+') { |o| o.puts Opal.process('core_spec') }
  File.open('build/grammar_spec.js', 'w+') { |o| o.puts Opal.process('grammar_spec') }
  File.open('build/specs.js', 'w+') { |o| o.puts Opal.process('spec_helper') }
end

task :default => [:build_specs, :parser, :test]

desc "Run opal specs through phantomjs"
task :test do
  OpalSpec.runner
end

task :dir do
  require 'fileutils'
  FileUtils.mkdir_p 'build'
end

desc "opal.min.js and opal-parser.min.js"
task :min do
  %w[opal opal-parser].each do |file|
    puts " * #{file}.min.js"
    File.open("build/#{file}.min.js", "w+") do |o|
      o.puts uglify(File.read "build/#{file}.js")
    end
  end
end

desc "Check file sizes for opal.js runtime"
task :sizes do
  o = File.read 'build/opal.js'
  m = uglify o
  g = gzip m

  puts "opal.js:"
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
