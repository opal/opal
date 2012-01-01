require 'bundler/setup'
require 'bundler/gem_tasks'
require 'opal'
require 'fileutils'
require 'opal/builder_task'

Opal::BuilderTask.new do |s|
  s.config :default do
    s.out = 'runtime/opal.js'
    s.builder = proc { Opal.build_runtime }
  end

  s.config :debug do
    s.out = 'runtime/opal.debug.js'
    s.builder = proc { Opal.build_runtime true }
  end

  s.config :test do
    s.out = 'runtime/opal.test.js'
    s.files = Dir['runtime/spec/**/*.rb']
    s.stdlib = ['forwardable']
    s.debug = false
    # main handled in spec_runner.html
  end
end

desc "Build opal.js and opal.debug.js into runtime/"
task :opal => ['opal:default', 'opal:debug']

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
