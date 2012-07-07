require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'

task :build_dir do
  FileUtils.mkdir_p 'build'
end

desc "Build opal runtime"
task :opal => :build_dir do
  File.open('build/opal.js', 'w+') do |o|
    puts " * opal"
    o.puts Opal.runtime
  end
end

desc "Build opal dependencies and runtime"
task :dependencies => :build_dir do
  %w(opal-spec opal-dom).each do |name|
    File.open("build/#{ name }.js", 'w+') do |o|
      puts " * #{ name }"
      o.puts Opal.build_gem(name)
    end
  end
end

desc "Build specs for runtime/corelib"
task :spec => :build_dir do
  File.open('build/opal.specs.js', 'w+') do |o|
    puts " * opal.specs"
    o.puts Opal.build_files('test')
  end
end

desc "Build dependencies and specs"
task :build => [:opal, :dependencies, :spec]

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

# Test
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :default
