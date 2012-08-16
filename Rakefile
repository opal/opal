require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'
require 'opal/rake_task'

Opal::RakeTask.new do |t|
  t.dependencies = %w(opal-spec)
  t.specs_dir    = 'test'
  t.files        = []  # we handle this by Opal.runtime instead
end

desc "Build opal-parser ready for browser"
task :parser do
  puts " * build/opal-parser.js"
  File.open('build/opal-parser.js', 'w+') do |o|
    o.puts Opal.build_gem 'opal-strscan'
    o.puts Opal.build_gem 'opal-racc'
    files = %w(grammar lexer parser scope).map { |f| "lib/opal/#{f}.rb" }
    o.puts Opal::Builder.new(:files => files).build
  end
end

desc "Build opal, dependencies, specs and opal-parser"
task :build => [:opal, :parser]

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

desc "Debug build of racc"
task :racc_debug do
  %x(racc -l -g lib/opal/grammar.y -o lib/opal/grammar.rb)
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

# Test
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :default

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

    %w(try).each do |src|
      puts " * src.md"
      File.open("gh-pages/#{src}.html", 'w+') do |out|
        out.write File.read("docs/pre.html")
        out.write File.read("docs/#{src}.html")
        out.write File.read("docs/post.html")
      end
    end

    %w(opal opal-parser).each do |src|
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
