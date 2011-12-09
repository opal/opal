require 'bundler/gem_tasks'
require 'opal'
require 'opal/bundle_task'
require 'fileutils'

header = <<-HEAD
/*!
 * opal v#{Opal::VERSION}
 * http://opalscript.org
 *
 * Copyright 2011, Adam Beynon
 * Released under the MIT license
 */
HEAD

Opal::BundleTask.new do |s|
  s.config :test do
    s.out = 'opal.test.js'
    s.files = Dir['spec/**/*.rb']
    s.main  = 'spec/spec_helper.rb'
    s.gem 'opaltest', git: 'git://github.com/adambeynon/opaltest.git'
    s.stdlib = %w[rbconfig optparse forwardable]
  end
end

desc "Rebuild core opal runtime into opal.js"
task :opal do
  parser  = Opal::Parser.new
  order   = File.read('corelib/load_order').strip.split
  core    = order.map { |c| File.read("corelib/#{c}.rb") }
  jsorder = File.read('corelib/js_order').strip.split
  jscode  = jsorder.map { |j| File.read("corelib/#{j}.js") }

  # runtime
  parsed = parser.parse core.join
  code   = "var core_lib = #{ parser.wrap_core_with_runtime_helpers(parsed) };"

  methods = Opal::Parser::METHOD_NAMES.to_a.map { |a| "'#{a[0]}': '#{a[1]}'" }

  # boot - bare code to be used in output projects
  File.open(Opal::OPAL_JS_PATH, 'w+') do |f|
    f.puts header
    f.puts "(function(undefined) {"
    f.puts jscode.join
    f.puts code
    f.puts "var method_names = {#{methods.join ', '}};"
    f.puts "var reverse_method_names = {}; for (var id in method_names) {"
    f.puts "reverse_method_names[method_names[id]] = id;}"
    f.puts "core_lib(rb_top_self, '(runtime)');"
    f.puts "}).call(this);"
  end
end

desc "Run opal tests"
task :test => :opal do
  Opal::Context.runner 'spec/**/*.rb'
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
