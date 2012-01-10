require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'

task :runtime do
  File.open('opal.js', 'w+') do |o|
    o.puts HEADER
    o.puts '(function(undefined) {'
    o.puts kernel_source(false)
    o.puts method_names
    o.puts corelib_source(false)
    o.puts '}).call(this);'
  end
end

task :debug_runtime do
  File.open('opal.debug.js', 'w+') do |o|
    o.puts HEADER
    o.puts '(function(undefined) {'
    o.puts kernel_source(true)
    o.puts method_names
    o.puts corelib_source(true)
    o.puts '}).call(this);'
  end
end

namespace :opal do
  desc "Tests for browser to opal.test.js"
  task :test do
    Opal::Builder.new('runtime/spec', :join => 'opal.test.js', :debug => true).build
  end
end

desc "Build dependencies into ."
task :dependencies do
  Opal::DependencyBuilder.new(gems: 'opal-spec', stdlib: 'forwardable').build
end

desc "Build opal.js and opal.debug.js opal into ."
task :opal => %w(runtime debug_runtime)

desc "Run opal specs (from runtime/spec/*)"
task :test => :opal do
  Opal::Context.runner 'runtime/spec/**/*.rb'
end

desc "Check file sizes for core builds"
task :sizes do
  sizes 'opal.js'
  sizes 'opal.debug.js'
end

desc "Rebuild grammar.rb for opal parser"
task :parser do
  %x(racc -l lib/opal/parser/grammar.y -o lib/opal/parser/grammar.rb)
end

namespace :docs do
  task :clone do
    if File.exists? 'gh-pages'
     Dir.chdir('gh-pages') { sh 'git pull origin gh-pages' }
    else
      FileUtils.mkdir_p 'gh-pages'
      Dir.chdir('gh-pages') do
        sh 'git clone git@github.com:/adambeynon/opal.git .'
        sh 'git checkout gh-pages'
      end
    end
  end

  desc "Copy required files into gh-pages dir"
  task :copy => :browser do
    %w[opal.js opal.debug.js index.html].each do |f|
      FileUtils.cp f, "gh-pages/#{f}"
    end
  end
end

HEADER = <<-HEADER
/*!
 * opal v#{Opal::VERSION}
 * http://opalrb.org
 *
 * Copyright 2012, Adam Beynon
 * Released under the MIT license
 */
HEADER

# Returns the source ruby code for the corelib as a string. Corelib is
# always parsed as one large file.
# @return [String]
def corelib_source(debug = false)
  order  = File.read('runtime/corelib/load_order').strip.split
  parser = Opal::Parser.new :debug => debug

  if debug
    order << 'debug'
    order.map do |c|
      parsed = parser.parse File.read("runtime/corelib/#{c}.rb"), c
      "opal.FILE = '/corelib/#{c}.rb';\n#{parsed}"
    end.join("\n")

  else
    source = order.map { |c| File.read "runtime/corelib/#{c}.rb" }.join("\n")
    parser.parse source, '(corelib)'
  end
end

# Returns javascript source for the kernel/runtime of opal.
# @return [String]
def kernel_source(debug = false)
  order = File.read('runtime/kernel/load_order').strip.split
  order << 'debug' if debug
  order.map { |c| File.read "runtime/kernel/#{c}.js" }.join("\n")
end

# Get all special method names from the parser and generate js code that
# is passed into runtime. This saves having special names duplicated in
# runtime AND parser.
# @return [String]
def method_names
  methods = Opal::Parser::METHOD_NAMES.map { |f, t| "'#{f}': '$#{t}$'" }
  %Q{
    var method_names = {#{ methods.join ', ' }};
    var reverse_method_names = {};
    for (var id in method_names) {
      reverse_method_names[method_names[id]] = id;
    }
  }
end

# Takes a file path, reads it and prints out the file size as it is, once
# minified and once minified + gzipped. Depends on uglifyjs being installed
# for node.js
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
