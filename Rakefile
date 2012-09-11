require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'
require 'opal/rake_task'

desc "REMOVE THIS"
task :handlebars do
  content = 'Email: {{text_field email limit="400"}}'
  puts Opal::Handlebars.new.compile(content)
end

Opal::RakeTask.new do |t|
  t.dependencies = %w(opal-spec)
  t.files        = []   # we handle this by Opal.runtime instead
  t.parser       = true # we want to also build opal-parser.js
end

desc "Run tests"
task :test do
  src = %w(build/opal.js build/opal-spec.js build/opal-parser.js build/specs.js)
  out = 'build/phantom_runner.js'

  File.open(out, 'w+') do |o|
    src.each { |s| o.write File.read(s) }
  end

  sh "phantomjs build/phantom_runner.js"
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
  %x(racc -l src/grammar.y -o lib/opal/grammar.rb)
  %x(racc -l src/handlebars_grammar.y -o lib/opal/handlebars_grammar.rb)
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