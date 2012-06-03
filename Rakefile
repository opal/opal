require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'

Opal::BuilderTask.new do |t|
  t.name         = 'opal'
  t.files        = []
  t.dependencies = %w[opal-spec]
  t.specs_dir    = 'test'
end

desc "Build opal.js runtime into ./build"
task :build do
  File.open('build/opal.js', 'w+') do |o|
    o.write Opal::Builder.runtime
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

# Rubygems
namespace :gem do
  desc "Build opal-#{Opal::VERSION}.gem"
  task :build do
    sh "gem build opal.gemspec"
  end

  desc "Release opal-#{Opal::VERSION}.gem"
  task :release do
    puts "Need to release opal-#{Opal::VERSION}.gem"
  end
end