$:.unshift File.expand_path('lib')
require 'opal'

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

task :build   => ["opal.js", "opal-parser.js"]
task :default => :build

task :clean do
  rm_rf Dir['*.js']
end

file "opal.js" do
  File.open("opal.js", "w+") do |file|
    builder = Opal::Builder.new
    file.write builder.build_core
  end
end

file "opal-parser.js" do
  File.open("opal-parser.js", "w+") do |file|
    builder = Opal::Builder.new
    file.write builder.build_parser
  end
end

desc "Check file sizes for core builds"
task :file_sizes => :build do
  o = File.read "opal.js"
  m = uglify(o)
  g = gzip(m)

  puts "development: #{o.size}, minified: #{m.size}, gzipped: #{g.size}"
end

desc "Rebuild ruby_parser.rb for opal build tools"
task :parser do
  %x{racc -l lib/opal/parser.y -o lib/opal/parser.rb}
end

