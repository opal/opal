require 'bundler/setup'
require 'opal/rake_task'

task :test_code do
  File.open('build/test_code.js', 'w+') do |out|
    require 'opal/processor'

    env = Sprockets::Environment.new
    env.append_path 'spec'
    out.puts env['spec_helper'].to_s
  end
end

Opal::RakeTask.new do |t|
  t.dependencies = %w(opal-spec)
  t.files        = []   # we handle this by Opal.runtime instead
  t.parser       = true # we want to also build opal-parser.js (used in specs)
end

# build runtime, dependencies and specs, then run the tests
task :default => %w[opal opal:test]

desc "opal.min.js and opal-parser.min.js"
task :min do
  %w[opal opal-parser].each do |file|
    puts " * #{file}.min.js"
    File.open("build/#{file}.min.js", "w+") do |o|
      o.puts uglify(File.read "build/#{file}.js")
    end
  end
end

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

# For testing just specific sections of opal
desc "Build each test case into build/"
task :test_cases do
  FileUtils.mkdir_p 'build/test_cases'

  sources = Dir['spec/core/*', 'spec/language', 'spec/parser', 'spec/grammar']

  sources.each do |c|
    dest = "build/test_cases/#{File.basename c}"
    FileUtils.mkdir_p dest
    File.open("#{dest}/specs.js", "w+") do |out|
      out.puts Opal.build_files(c)
    end

    File.open("#{dest}/index.html", "w+") do |out|
      out.puts File.read("spec/test_case.html")
    end
  end

  File.open("build/test_cases/runner.js", "w+") do |out|
    out.puts Opal.parse(File.read("spec/spec_helper.rb"))
  end
end