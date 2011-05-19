$:.unshift File.expand_path(File.join('..', 'opalite'), __FILE__)
require 'opal'
require 'fileutils'

copyright = <<-EOS
/*!
 * Opal v0.3.2
 * http://opalscript.org
 *
 * Copyright 2011, Adam Beynon
 * Released under the MIT license
 */
EOS

desc "Build opal.js package ready for the browser"
task :browser do
  builder = Opal::Builder.new :files => %w[lib/core.rb lib/core/*.rb],
                              :out   => 'extras/opal.js',
                              :pre   => copyright + File.read('runtime.js'),
                              :post  => "opal.require('core');"

  builder.build
end

desc "Build ospec package into extras/opal.spec.js ready for browser tests"
task :ospec do
  FileUtils.mkdir_p 'extras'

  gem = Opal::Gem.new File.dirname(__FILE__)
  content = gem.bundle :dependencies => 'ospec', :main => 'ospec/autorun', :test_files => true
  File.open('extras/opal.spec.js', 'w+') { |out| out.write content }
end

require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--title', 'Documentation for Opal Core Library',
              '--markup', 'markdown']
end

