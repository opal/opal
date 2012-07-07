require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'

def build_to(file, &code)
  File.open("build/#{file}.js", 'w+') { |o| o.puts code.call }
end

desc "Build runtime, test dependencies and specs"
task :build do
  FileUtils.mkdir_p 'build'

  build_to('opal') { Opal.runtime }
  build_to('opal-spec') { Opal.build_gem 'opal-spec' }
  build_to('opal-dom') { Opal.build_gem 'opal-dom' }
  build_to('specs') { Opal.build_files 'test' }
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

# Test
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :default
