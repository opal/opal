$:.unshift File.expand_path('lib')
require "opal"
require "opal/version"
require "fileutils"

COPYRIGHT = <<-EOS
/*!
 * opal v#{Opal::VERSION}
 * http://opalscript.org
 *
 * Copyright 2011, Adam Beynon
 * Released under the MIT license
 */
EOS

RUNTIME_PATH = File.join Dir.getwd, "runtime"
CORE_PATH    = File.join Dir.getwd, "corelib"

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

# Builds core opal runtime and corelib to opal.js. This is not stored
# in source control, but is included in the gem.
desc "Build opal runtime and corelib ready for the browser"
file "opal.js" do
  File.open("opal.js", "w+") do |file|
    builder = Opal::Builder.new
    code    = COPYRIGHT
    order   = File.read("#{CORE_PATH}/load_order").strip.split
    core    = order.map { |c| File.read "#{CORE_PATH}/#{c}.rb" }

    %w[pre runtime init class module fs loader].each do |r|
      code += File.read("#{RUNTIME_PATH}/#{r}.js")
    end

    code += "var core_lib = #{builder.parse core.join};"
    code += File.read "#{RUNTIME_PATH}/post.js"

    file.write code
  end
end

# Builds the parser as well as all files needed for running the parser
# and compiler in the browser. Also includes racc/parser and strscan.
desc "Build opal parser ready to use in the web browser"
file "opal-parser.js" do
  File.open("opal-parser.js", "w+") do |file|
    builder = Opal::Builder.new
    code    = COPYRIGHT

    %w[opal/nodes opal/lexer opal/parser].each do |s|
      js = File.read("lib/#{s}.rb")
      code += "opal.lib('#{s}', #{builder.parse js});"
    end

    code += builder.build_stdlib('racc/parser', 'strscan', 'dev')
    code += "opal.require('dev');"

    file.write code
  end
end

task :build   => ["opal.js", "opal-parser.js"]
task :default => :build

task :clean do
  rm_rf Dir['*.js']
end

desc "Check file sizes for core builds"
task :sizes => :build do
  o = File.read "opal.js"
  m = uglify(o)
  g = gzip(m)

  puts "development: #{o.size}, minified: #{m.size}, gzipped: #{g.size}"
end

desc "Rebuild ruby_parser.rb for opal build tools"
task :parser do
  %x{racc -l lib/opal/parser.y -o lib/opal/parser.rb}
end

task :docs do
  system "jekyll"
end

namespace :docs do
  task :publish => :build do
    if File.exist? "gh-pages"
      puts "./gh-pages already exists, so skipping clone"
    else
      sh "git clone -b gh-pages git@github.com:adambeynon/opal.git gh-pages"
    end
    FileUtils.cp_r "docs/_site/.", "gh-pages", :verbose => true
  end
end

