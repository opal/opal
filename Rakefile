# FIXME: there must be a better way
Encoding.default_external = 'utf-8'

require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

import 'tasks/github.rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/lib/**/*_spec.rb'
end

require 'mspec/opal/rake_task'
MSpec::Opal::RakeTask.new(:mspec) do |config|
  config.pattern = ENV['MSPEC_PATTERN'] if ENV['MSPEC_PATTERN']
  config.basedir = ENV['MSPEC_BASEDIR'] if ENV['MSPEC_BASEDIR']
end

task :default => [:rspec, :mspec_node]


task :mspec_node do
  rubyspecs = File.read('spec/rubyspecs').lines.reject do |l|
    l.strip!; l.start_with?('#') || l.empty?
  end.flat_map do |path|
    path = "spec/#{path}"
    File.directory?(path) ? Dir[path+'/*.rb'] : "#{path}.rb"
  end

  filters = Dir['spec/filters/**/*.rb']
  shared = Dir['spec/{opal,lib/parser}/**/*_spec.rb'] + ['spec/lib/lexer_spec.rb']

  specs = []
  add_specs = ->(name, new_specs) { p [new_specs.size, name]; specs + new_specs}

  specs = add_specs.(:filters, filters)
  pattern = ENV['PATTERN']
  whitelist_pattern = !!ENV['RUBYSPECS']

  if pattern
    custom = Dir[pattern]
    custom &= rubyspecs if whitelist_pattern
    specs = add_specs.(:custom, custom)
  else
    specs = add_specs.(:shared, shared)
    specs = add_specs.(:rubyspecs, rubyspecs)
  end

  requires = specs.map{|s| "require '#{s.sub(/^spec\//,'')}'"}
  filename = 'tmp/mspec_node.rb'
  mkdir_p File.dirname(filename)
  File.write filename, <<-RUBY
    require 'spec_helper'
    #{requires.join("    \n")}
    OSpecRunner.main.did_finish
  RUBY

  stubs = " -smspec/helpers/tmp -smspec/helpers/environment -smspec/guards/block_device -smspec/guards/endian"

  exec 'RUBYOPT="-rbundler/setup -rmspec/opal/special_calls" '\
       "bin/opal -Ispec -Ilib -gmspec #{stubs} -rnodejs -Dwarning -A #{filename}"
end

require 'opal/version'
desc <<-DESC
Build *corelib* and *stdlib* to "build/"

You can restrict the file list with the FILES env var (comma separated)
and the destination dir with the DIR env var.

Example: rake dist DIR=/tmp/foo FILES='opal.rb,base64.rb'
Example: rake dist DIR=cdn/opal/#{Opal::VERSION}
Example: rake dist DIR=cdn/opal/master
DESC
task :dist do
  require 'opal/util'

  Opal::Processor.arity_check_enabled = false
  Opal::Processor.const_missing_enabled = false
  Opal::Processor.dynamic_require_severity = :warning
  env = Opal::Environment.new

  build_dir = ENV['DIR'] || 'build'
  files     = ENV['FILES'] ? ENV['FILES'].split(',') :
              Dir['{opal,stdlib}/*.rb'].map { |lib| File.basename(lib, '.rb') }

  Dir.mkdir build_dir unless File.directory? build_dir
  width = files.map(&:size).max

  files.each do |lib|
    print "* building #{lib}...".ljust(width+'* building ... '.size)
    $stdout.flush

    src = env[lib].to_s
    min = Opal::Util.uglify src
    gzp = Opal::Util.gzip min

    File.open("#{build_dir}/#{lib}.js", 'w+')        { |f| f << src }
    File.open("#{build_dir}/#{lib}.min.js", 'w+')    { |f| f << min } if min
    File.open("#{build_dir}/#{lib}.min.js.gz", 'w+') { |f| f << gzp } if gzp

    print "done. ("
    print "development: #{('%.2f' % (src.size/1000.0)).rjust(6)}KB"
    print  ", minified: #{('%.2f' % (min.size/1000.0)).rjust(6)}KB" if min
    print   ", gzipped: #{('%.2f' % (gzp.size/1000.0)).rjust(6)}KB" if gzp
    puts  ")."
  end
end

desc 'Rebuild grammar.rb for opal parser'
task :racc do
  %x(racc -l lib/opal/parser/grammar.y -o lib/opal/parser/grammar.rb)
end

desc 'Remove any generated file.'
task :clobber do
  rm_r './build'
end

namespace :doc do
  doc_repo = Pathname(ENV['DOC_REPO'] || 'gh-pages')
  doc_base = doc_repo.join('doc')
  current_git_release = -> { `git rev-parse --abbrev-ref HEAD`.chomp }
  template_option = "--template opal --template-path #{doc_repo.join('yard-templates')}"

  directory doc_repo.to_s do
    remote = ENV['DOC_REPO_REMOTE'] || '.'
    sh 'git', 'clone', '-b', 'gh-pages', '--', remote, doc_repo.to_s
  end

  task :corelib => doc_repo.to_s do
    git  = current_git_release.call
    name = 'corelib'
    glob = 'opal/**/*.rb'

    command = "doxx --template #{doc_repo.join('doxx-templates/opal.jade')} "\
              "--source opal/corelib --target #{doc_base}/#{git}/#{name} "\
              "--title \"Opal runtime.js Documentation\" --readme opal/README.md"
    puts command; system command or $stderr.puts "Please install doxx with: npm install"

    command = "yard doc #{glob} #{template_option} "\
              "--readme opal/README.md -o #{doc_base}/#{git}/#{name}"
    puts command; system command
  end

  task :stdlib => doc_repo do
    git  = current_git_release.call
    name = 'stdlib'
    glob = '{stdlib/**/*,opal/compiler,opal/erb,opal/version}.rb'
    command = "yard doc #{glob} #{template_option} "\
              "--readme stdlib/README.md -o gh-pages/doc/#{git}/#{name}"
    puts command; system command
  end
end

task :doc => ['doc:corelib', 'doc:stdlib']
