#!/usr/bin/env rake


# BUNDLER

begin
  require 'bundler/setup'
  # require 'bundler/gem_tasks'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks




# DOCS

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Opal::Rails'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end




# TEST

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :default
