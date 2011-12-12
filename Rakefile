require 'bundler/gem_tasks'
require 'opal'
require 'opal/builder_task'
require 'fileutils'

desc "Rebuild opal.js" 
task :opal do
  Dir.chdir "runtime" do
    puts sh("rake opal")
    puts sh("rake opal_debug")
  end
end

desc "Run opal tests"
task :test => :opal do
  Opal::Context.runner 'runtime/spec/**/*.rb'
end

desc "Check file sizes for core builds"
task :sizes do
  o = File.read Opal::OPAL_JS_PATH
  m = uglify(o)
  g = gzip(m)

  File.open('vendor/opal.min.js', 'w+') { |o| o.write m }

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
