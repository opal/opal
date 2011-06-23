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

task :build   => ["extras/opal-#{VERSION}.js", "extras/opal-parser-#{VERSION}.js"]
task :min     => ["extras/opal-#{VERSION}.min.js", "extras/opal-parser-#{VERSION}.min.js"]
task :default => :min

file "extras" do
  mkdir_p "extras"
end

task :clean do
  rm_rf Dir['extras/*.js']
end

file "extras/opal-#{VERSION}.js" => "extras" do
  File.open("extras/opal-#{VERSION}.js", "w+") do |file|
    file.write opal_copyright
    file.write Opal::Builder.new.build_core
  end
end

file "extras/opal-#{VERSION}.min.js" => "extras/opal-#{VERSION}.js" do
  File.open("extras/opal-#{VERSION}.min.js", "w+") do |file|
    file.write opal_copyright
    file.write uglify(Opal::Builder.new.build_core)
  end
end
file "extras/opal-#{VERSION}.test.js" => "extras" do
  File.open("extras/opal-#{VERSION}.test.js", "w+") do |file|
    builder = Opal::Builder.new
    Dir["spec/**/*.rb"].each do |spec|
      file.write builder.wrap_source(spec, spec)
    end
    # opal.require('ospec/autorun')
  end
end

file "extras/opal-parser-#{VERSION}.js" => "extras" do
  File.open("extras/opal-parser-#{VERSION}.js", "w+") do |file|
    file.write opal_copyright
    file.write Opal::Builder.new.build_parser
  end
end

file "extras/opal-parser-#{VERSION}.min.js" => "extras/opal-parser-#{VERSION}.js" do
  File.open("extras/opal-parser-#{VERSION}.min.js", "w+") do |file|
    file.write opal_copyright
    file.write uglify(Opal::Builder.new.build_parser)
  end
end

file "extras/ospec-#{VERSION}.js" => "extras" do
  File.open("extras/ospec-#{VERSION}.js", "w+") do |file|
    file.write opal_copyright
    file.write Opal::Builder.new.build_stdlib 'ospec.rb', 'ospec/**/*.rb'
  end
end

desc "Check file sizes for core builds"
task :file_sizes => :min do
  n = File.read("extras/opal-#{VERSION}.js")
  m = File.read("extras/opal-#{VERSION}.min.js")
  g = gzip(m)

  puts "unminified: #{n.size}, minified: #{m.size}, gzipped: #{g.size}"
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

namespace :web do

end

