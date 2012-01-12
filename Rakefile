require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'

begin
  require 'rocco'
rescue LoadError
end

task :runtime do
  FileUtils.rm_f 'opal.js'
  code = Opal.runtime_code
  File.open('opal.js', 'w+') { |o| o.write code }
end

task :debug_runtime do
  FileUtils.rm_f 'opal.debug.js'
  code = Opal.runtime_debug_code
  File.open('opal.debug.js', 'w+') { |o| o.write code }
end

namespace :opal do
  desc "Tests for browser to opal.test.js"
  task :test do
    sh "bundle exec bin/opal build core_spec"
  end
end

desc "Build dependencies into ."
task :dependencies do
  sh "bundle exec bin/opal dependencies"
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
  task :copy => :opal do
    %w[opal.js opal.debug.js index.html].each do |f|
      FileUtils.cp f, "gh-pages/#{f}"
    end
  end

  desc "rocco"
  task :rocco do
    FileUtils.mkdir_p 'docs'
    %w[builder dependency_builder].each do |src|
      path = "lib/opal/#{src}.rb"
      out  = "docs/#{src}.html"

      File.open(out, 'w+') { |o| o.write Rocco.new(path).to_html }
    end
  end
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
