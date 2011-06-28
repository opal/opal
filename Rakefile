$:.unshift File.expand_path(File.join('..', 'opal_lib'), __FILE__)
require 'opal'

VERSION = File.read('VERSION').strip

opal_copyright = <<-EOS
/*!
 * opal v#{VERSION}
 * http://opalscript.org
 *
 * Copyright 2011, Adam Beynon
 * Released under the MIT license
 */
EOS

def uglify(str)
  IO.popen('uglifyjs -nc', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end

def gzip(str)
  IO.popen('gzip -f', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
end

task :build   => ["extras/opal.js", "extras/opal-parser.js"]
task :default => :build

file "extras" do
  mkdir_p "extras"
end

task :clean do
  rm_rf Dir['extras/*.js']
end

file "extras/opal.js" => "extras" do
  File.open("extras/opal.js", "w+") do |file|
    file.write opal_copyright
    file.write uglify(Opal::Builder.new.build_core)
  end
end

file "extras/opal.test.js" => "extras" do
  File.open("extras/opal.test.js", "w+") do |file|
    builder = Opal::Builder.new
    Dir["spec/**/*.rb"].each do |spec|
      file.write builder.wrap_source(spec, spec)
    end
    # opal.require('ospec/autorun')
  end
end

file "extras/opal-parser.js" => "extras" do
  File.open("extras/opal-parser.js", "w+") do |file|
    file.write opal_copyright
    file.write uglify(Opal::Builder.new.build_parser)
  end
end

file "extras/ospec.js" => "extras" do
  File.open("extras/ospec.js", "w+") do |file|
    file.write opal_copyright
    file.write Opal::Builder.new.build_stdlib 'ospec.rb', 'ospec/**/*.rb'
  end
end

desc "Check file sizes for core builds"
task :file_sizes => :build do
  m = File.read("extras/opal.js")
  g = gzip(m)

  puts "minified: #{m.size}, gzipped: #{g.size}"
end

desc "Rebuild ruby_parser.rb for opal build tools"
task :parser do
  %x{racc -l opal_lib/opal/ruby/ruby_parser.y -o opal_lib/opal/ruby/ruby_parser.rb}
end

namespace :starter_kit do
  starter_kit_dir = "extras/starter-kit"
  js_sources = ["opal-#{VERSION}.js", "opal-#{VERSION}.min.js", "opal-parser-#{VERSION}.js", "opal-parser-#{VERSION}.min.js"]
  js_target = "#{starter_kit_dir}/js"

  file starter_kit_dir => "extras" do
    sh "git clone git@github.com:opal/starter-kit.git #{starter_kit_dir}"
  end

  task :pull => starter_kit_dir do
    Dir.chdir(starter_kit_dir) { sh "git pull origin master" }
  end

  task :js_sources do
    js_sources.each do |src|
      sh "cp extras/#{src} #{js_target}/#{src}"
    end
  end

  task :build => [:min, starter_kit_dir]
end

namespace :gh_pages do

  task :pull do
    rm_rf "gh_pages"
    sh "git clone git@github.com:adambeynon/opal.git gh_pages"
    Dir.chdir("gh_pages") do
      sh "git checkout gh-pages"
    end
  end

  task :server do
    Dir.chdir("docs") do
      sh "jekyll --server"
    end
  end

  task :js => "build" do
    cp "extras/opal.js", "docs/js/opal.js"
    cp "extras/opal-parser.js", "docs/js/opal-parser.js"
  end
end

