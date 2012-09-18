require 'bundler/setup'
require 'opal'

desc "Build opal runtime, specs and dependencies into build/"
task "opal" do
  # runtime
  build_to "opal.js", Opal.runtime

  # parser
  build_to "opal-parser.js", Opal.parser_code

  # dependencies
  %w[opal-spec].each { |name| build_to "#{name}.js", Opal.build_gem(name) }

  # specs
  build_to 'specs.js', Opal.build_files('spec')
end

def build_to(path, code)
  FileUtils.mkdir_p 'build'
  out = "build/#{path}"
  puts " * #{out}"
  File.open(out, 'w+') { |out| out.puts code }
end

desc "Run core specs"
task :test do
  sh "phantomjs vendor/phantom_runner.js spec/index.html"
end

task :default => :test

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