require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'

DEPENDENCIES = {
  "opal-spec" => "git@github.com:adambeynon/opal-spec.git"
}

HEADER = <<-EOS
/*!
 * Opal v#{Opal::VERSION}
 * http://opalrb.org
 *
 * Copyright 2012, Adam Beynon
 * Released under the MIT License
 */
 EOS

Opal::Builder.setup do |p|
  p.specs_dir = 'core_spec'
end

desc "Put all dependencies into vendor/"
task :dependencies do
  DEPENDENCIES.each do |dep, url|
    path = File.join "vendor/#{dep}"
    if File.exists? path
      puts "Skipping #{dep}"
    else
      sh "git clone #{url} vendor/#{dep}"
    end
  end
end

desc "Build each dependency (into its own build/ dir)"
task :build_deps do
  DEPENDENCIES.each do |dep, url|
    Dir.chdir(File.join 'vendor', dep) do
      puts "- #{dep}"
      sh "rake build"
    end
  end
end

desc "Build opal.js into build/"
task :opal do
  FileUtils.rm_f 'build/opal.js'

  parser = Opal::Parser.new
  code   = []
  core   = File.read('core/load_order').strip.split.map do |c|
    File.read "core/#{c}.rb"
  end

  methods = Opal::Parser::METHOD_NAMES.map { |f, t| "'#{f}': '$#{t}$'"}
  names   = %Q{
    var method_names = {#{ methods.join ', ' }};
    var reverse_method_names = {};
    for (var id in method_names) {
      reverse_method_names[method_names[id]] = id;
    }
  }

  code << HEADER
  code << '(function(undefined) {'
  code << File.read('core/runtime.js')
  code << names
  code << parser.parse(core.join "\n")
  code << '}).call(this);'

  FileUtils.mkdir_p 'build'
  File.open('build/opal.js', 'w+') do |o|
    o.puts code.join("\n")
  end
end

desc "Check file sizes for core builds"
task :sizes do
  sizes 'build/opal.js'
end

desc "Rebuild grammar.rb for opal parser"
task :parser do
  %x(racc -l lib/opal/grammar.y -o lib/opal/grammar.rb)
end

##
# Rubygems
#

desc "Build opal-#{Opal::VERSION}.gem"
task :gem do
  sh "gem build opal.gemspec"
end

desc "Release opal-#{Opal::VERSION}.gem"
task :release do
  puts "Need to release opal-#{Opal::VERSION}.gem"
end

##
# Documentation
#

begin
  require 'rocco'
rescue LoadError
end

namespace :docs do
  task :clone do
    if File.exists? 'gh-pages'
     Dir.chdir('gh-pages') { sh 'git pull origin gh-pages' }
    else
      FileUtils.mkdir_p 'gh-pages'
      Dir.chdir('gh-pages') do
        sh 'git clone git@github.com:/adambeynon/opal.git .'
        sh 'git checkout gh-pages'
      end
    end
  end

  desc "Copy required files into gh-pages dir"
  task :copy => :opal do
    %w[opal.js opal.debug.js index.html].each do |f|
      FileUtils.cp f, "gh-pages/#{f}"
    end
  end

  desc "rocco"
  task :rocco do
    FileUtils.mkdir_p 'docs'
    %w[builder dependency_builder].each do |src|
      path = "lib/opal/#{src}.rb"
      out  = "docs/#{src}.html"

      File.open(out, 'w+') { |o| o.write Rocco.new(path).to_html }
    end
  end
end

# Takes a file path, reads it and prints out the file size as it is, once
# minified and once minified + gzipped. Depends on uglifyjs being installed
# for node.js
def sizes file
  o = File.read file
  m = uglify o
  g = gzip m

  puts "#{file}:"
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
