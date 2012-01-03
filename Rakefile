require 'bundler/setup'
require 'bundler/gem_tasks'
require 'opal'
require 'fileutils'
require 'opal/builder_task'

namespace :browser do
  desc "Build opal runtime to runtime/opal.js"
  task :opal do
    File.open('runtime/opal.js', 'w+') { |o| o.write Opal.build_runtime }
  end

  desc "Build opal debug runtime to runtime/opal.debug.js"
  task :debug do
    File.open('runtime/opal.debug.js', 'w+') { |o| o.write Opal.build_runtime true }
  end

  desc "Tests for browser to runtime/opal.test.js"
  task :test do
    Opal::Compiler.new('runtime/spec', :join => 'runtime/opal.test.js').compile
  end
end

desc "Build opal.js and opal.debug.js into runtime/"
task :browser => [:'browser:opal', :'browser:debug']

desc "Run opal specs (from runtime/spec/*)"
task :test => :opal do
  Opal::Context.runner 'runtime/spec/**/*.rb'
end

desc "Check file sizes for core builds"
task :sizes do
  sizes 'runtime/opal.js'
  sizes 'runtime/opal.debug.js'
end

desc "Rebuild grammar.rb for opal parser"
task :parser do
  %x(racc -l lib/opal/parser/grammar.y -o lib/opal/parser/grammar.rb)
end

def sizes file
  o = File.read file
  m = uglify o
  g = gzip m

  puts "#{file}:"
  puts "development: #{o.size}, minified: #{m.size}, gzipped: #{g.size}"
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
