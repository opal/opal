$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require 'opal'
require 'fileutils'

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

