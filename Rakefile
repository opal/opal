require 'bundler/gem_tasks'
require 'opal'
require 'opal/bundle_task'
require 'fileutils'

SPEC_DIR = File.join(File.dirname(__FILE__), 'spec')

Opal::BundleTask.new

desc "Run opal tests"
task :test => :opal do
  if glob = ENV['TEST']
    glob = File.expand_path glob, SPEC_DIR
    glob += "/**/*.rb" if File.directory? glob
  end

  src = Dir[glob || 'spec/**/*.rb']

  abort "no matching tests for #{glob.inspect}" if src.empty?

  c = Opal::Context.new
  src.each { |s| c.eval File.read(s), s}
  c.finish
end

desc "Check file sizes for core builds"
task :sizes do
  o = File.read "opal.js"
  m = uglify(o)
  g = gzip(m)

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

task :docs => "docs:build"

namespace :docs do
  task :build => :build_js do
    Dir.chdir("docs") { system "jekyll" }
    %w[opal.js opal-parser.js].each do |s|
      FileUtils.cp s, "docs/_site/#{s}", :verbose => true
    end
  end

  task :publish do
    if File.exist? "gh-pages"
      puts "./gh-pages already exists, so skipping clone"
    else
      sh "git clone -b gh-pages git@github.com:adambeynon/opal.git gh-pages"
    end
    FileUtils.cp_r "docs/_site/.", "gh-pages", :verbose => true
  end
end

