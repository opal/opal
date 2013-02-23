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
  env = Sprockets::Environment.new
  Opal.paths.each { |p| env.append_path p }

  src = env['opal'].to_s
  min = uglify src
  gzp = gzip min

  puts "development: #{src.size}, minified: #{min.size}, gzipped: #{gzp.size}"
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
