require 'bundler/setup'
require 'opal/rake_task'

Opal::RakeTask.new do |t|
  t.dependencies = %w(opal-spec)
  t.files        = []   # we handle this by Opal.runtime instead
  t.parser       = true # we want to also build opal-parser.js (used in specs)
end

# build runtime, dependencies and specs, then run the tests
task :default => %w[opal opal:test]

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

  sources = Dir['spec/core/*', 'spec/language', 'spec/lib', 'spec/opal']

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

namespace :docs do
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
      # slightly change README contents with custom html headers etc (10 lines)
      src = File.read("README.md").sub(/^(?:[^\n]*\n){10}/, '')

      o.write File.read('docs/pre.html')
      o.write markdown.render(src)
      o.write File.read('docs/post.html')
    end
  end

  desc "Clone repo"
  task :clone do
    if File.exists? 'gh-pages'
     Dir.chdir('gh-pages') { sh 'git pull origin gh-pages' }
    else
      FileUtils.mkdir_p 'gh-pages'
      Dir.chdir('gh-pages') do
        sh 'git clone git@github.com:/opal/opal.git .'
        sh 'git checkout gh-pages'
      end
    end
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