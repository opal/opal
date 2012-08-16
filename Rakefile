require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'
require 'opal/rake_task'

Opal::RakeTask.new do |t|
  t.dependencies = %w(opal-spec)
  t.specs_dir    = 'test'
  t.files        = []  # we handle this by Opal.runtime instead
end

desc "Build opal-parser ready for browser"
task :parser do
  puts " * build/opal-parser.js"
  File.open('build/opal-parser.js', 'w+') do |o|
    o.puts Opal.build_gem 'opal-strscan'
    o.puts Opal.build_gem 'opal-racc'
    files = %w(grammar lexer parser scope).map { |f| "lib/opal/#{f}.rb" }
    o.puts Opal::Builder.new(:files => files).build
  end
end

desc "Build opal, dependencies, specs and opal-parser"
task :build => [:opal, :parser]

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

desc "Debug build of racc"
task :racc_debug do
  %x(racc -l -g lib/opal/grammar.y -o lib/opal/grammar.rb)
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
