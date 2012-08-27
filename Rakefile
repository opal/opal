require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'
require 'opal/rake_task'

Opal::RakeTask.new do |t|
  t.dependencies = %w(opal-spec)
  t.files        = []   # we handle this by Opal.runtime instead
end

desc "Build opal-parser ready for browser"
task :parser do
  puts " * build/opal-parser.js"
  File.open('build/opal-parser.js', 'w+') do |o|
    o.puts Opal::Builder.new(:files => %w(racc.rb strscan.rb), :dir => 'core').build
    o.puts Opal.build_gem('opal')
    o.puts File.read('core/browser.js')
  end
end

desc "Build minified versions of core js builds"
task :min do
  %w[opal opal-parser].each do |f|
    puts " * minify #{f}"
    File.open("build/#{f}.min.js", 'w+') do |o|
      o.puts uglify(File.read("build/#{f}.js"))
    end
  end
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

namespace :docs do
  desc "Clone repo"
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

  desc "Build docs"
  task :build do
    require 'redcarpet'
    require 'albino'

    klass = Class.new(Redcarpet::Render::HTML) do
      def block_code(code, language)
        Albino.new(code, language || :text).colorize
      end
    end

    markdown = Redcarpet::Markdown.new(klass, :fenced_code_blocks => true)

    File.open('gh-pages/index.html', 'w+') do |o|
      puts " * index.html"
      o.write File.read('docs/pre.html')
      o.write markdown.render(File.read "docs/index.md")
      o.write File.read('docs/post.html')
    end

    %w(try examples opal-spec specs implementation tools changelog).each do |src|
      puts " * #{src}.md"
      FileUtils.mkdir_p "gh-pages/#{src}"
      File.open("gh-pages/#{src}/index.html", 'w+') do |out|
        out.write File.read("docs/pre.html")
        out.write markdown.render(File.read("docs/#{src}.md"))
        out.write File.read("docs/post.html")
      end
    end

    %w(opal opal-parser opal.min opal-parser.min opal-spec specs).each do |src|
      puts " * #{src}.js"
      FileUtils.cp "build/#{src}.js", "gh-pages/#{src}.js"
    end
  end

  task :server do
    require 'rack'
    server = Class.new(Rack::Server) do
      def app
        Rack::Directory.new('gh-pages')
      end
    end

    server.new.start
  end

  desc "commit and push"
  task :push do
    Dir.chdir('gh-pages') do
      sh "git add ."
      sh "git commit -a -m \"Documentation update #{Time.new}\""
      sh "git push origin gh-pages"
    end
  end
end