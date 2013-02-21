require 'bundler'
Bundler.require

require 'opal/spec/rake_task'
Opal::Spec::RakeTask.new(:default)

desc "Run tests with method_missing turned off"
task :test_no_method_missing do
  # some specs will fail (namely method_missing based specs)
  Opal::Processor.method_missing_enabled = false
  Rake::Task[:default].invoke 
end

desc "Check file sizes for opal.js runtime"
task :sizes do
  o = Opal::Environment.new['opal'].to_s
  m = uglify o
  g = gzip m

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
