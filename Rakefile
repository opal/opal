$:.unshift File.expand_path(File.join('..', 'lib'), __FILE__)
require 'opal'
require 'yaml'

VERSION = YAML.load(File.read('package.yml'))['version']

opal_copyright = <<-EOS
/*!
 * opal v#{VERSION}
 * http://opal.org
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
    builder = Opal::Builder.new
    file.write opal_copyright
    file.write builder.build_core
  end
end

file "extras/opal-parser.js" => "extras" do
  File.open("extras/opal-parser.js", "w+") do |file|
    file.write opal_copyright
    file.write Opal::Builder.new.build_parser
  end
end

desc "Check file sizes for core builds"
task :file_sizes => :build do
  o = File.read "extras/opal.js"
  m = uglify(o)
  g = gzip(m)

  File.open("extras/opal.min.js", "w+") { |o| o.write m }
  puts "development: #{o.size}, minified: #{m.size}, gzipped: #{g.size}"
end

desc "Rebuild ruby_parser.rb for opal build tools"
task :parser do
  %x{racc -l lib/opal/parser.y -o lib/opal/parser.rb}
end

