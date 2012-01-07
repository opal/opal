require 'bundler/setup'
require 'bundler/gem_tasks'
require 'opal'
require 'fileutils'
require 'opal/version'

namespace :browser do
  desc "Build opal runtime to opal.js"
  task :opal do
    File.open("opal.js", 'w+') { |o| o.write build_runtime false }
  end

  desc "Build opal debug runtime to opal.debug.js"
  task :debug do
    File.open("opal.debug.js", 'w+') { |o| o.write build_runtime true }
  end

  desc "Tests for browser to opal.test.js"
  task :test do
    Opal::Builder.new('runtime/spec', :join => 'opal.test.js').build
  end

  desc "Build dependencies into runtime/"
  task :dependencies do
    Opal::DependencyBuilder.new(gems: %w[opal-spec], stdlib: 'forwardable', verbose: true).build
  end
end

desc "Build opal and debug opal into runtime/"
task :browser => [:'browser:opal', :'browser:debug']

desc "Run opal specs (from runtime/spec/*)"
task :test => :browser do
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
 * http://adambeynon.github.com/opal
 *
 * Copyright 2012, Adam Beynon
 * Released under the MIT license
 */
HEADER

def build_runtime debug = false
  rborder = File.read('runtime/corelib/load_order').strip.split
  rbcore  = rborder.map { |c| File.read "runtime/corelib/#{c}.rb" }
  jsorder = File.read('runtime/kernel/load_order').strip.split
  jscore  = jsorder.map { |c| File.read "runtime/kernel/#{c}.js" }

  parser  = Opal::Parser.new :debug => debug
  parsed  = parser.parse rbcore.join("\n"), '(corelib)'
  methods = Opal::Parser::METHOD_NAMES.map { |f, t| "'#{f}': 'm$#{t}$'" }
  result  = []

  result << '(function(undefined) {'
  result << jscore.join
  result << "var method_names = {#{methods.join ', '}};"
  result << "var reverse_method_names = {}; for (var id in method_names) {"
  result << "reverse_method_names[method_names[id]] = id;}"
  result << parsed
  result << '}).call(this);'

  HEADER + result.join("\n")
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
