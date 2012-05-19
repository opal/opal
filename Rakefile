require 'fileutils'
require 'bundler'
Bundler.setup

require 'opal'
require 'opal/version'

desc "Build opal.js runtime into ./build"
task :opal do
  File.open('build/opal.js', 'w+') do |o|
    o.write Opal::Builder.runtime
  end
end

Opal::BuilderTask.new do |t|
  t.name  = 'opal'
  t.files = []
  t.dependencies = %w[opal-spec opal-racc opal-strscan]
end

desc "Check file sizes for opal.js runtime"
task :sizes do
  o = File.read 'build/opal.js'
  m = uglify o
  g = gzip m

  puts "#{opal.js}:"
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

# Rubygems
namespace :gem do
  desc "Build opal-#{Opal::VERSION}.gem"
  task :build do
    sh "gem build opal.gemspec"
  end

  desc "Release opal-#{Opal::VERSION}.gem"
  task :release do
    puts "Need to release opal-#{Opal::VERSION}.gem"
  end
end

# Documentation
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

  task :index do
    require 'redcarpet'
    require 'albino'

    klass = Class.new(Redcarpet::Render::HTML) do
      def block_code(code, language)
        Albino.new(code, language || :text).colorize
      end
    end

    markdown = Redcarpet::Markdown.new(klass, :fenced_code_blocks => true)

    File.open('gh-pages/index.html', 'w+') do |o|
      o.write File.read('docs/pre.html')
      o.write markdown.render(File.read 'docs/index.md')
      o.write markdown.render(File.read 'CHANGELOG.md')
      o.write File.read('docs/post.html')
    end
  end

  task :copy do
    FileUtils.cp 'build/opal.js',   'gh-pages/opal.js'
    FileUtils.cp 'docs/styles.css', 'gh-pages/styles.css'
    FileUtils.cp 'docs/syntax.css', 'gh-pages/syntax.css'
  end
end