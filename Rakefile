$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require 'opal'

require 'fileutils'

desc "Build browser version of opal into extras/opal.js"
task :opal_js do
  FileUtils.mkdir_p 'extras'

  gem = Opal::Gem.new File.join(__FILE__, '..', '..', 'rquery')
  content = gem.bundle
  File.open('extras/opal.js', 'w+') { |out| out.write content }
end

desc "Build ospec package into tmp/ ready for browser tests"
task :ospec do
  FileUtils.mkdir_p 'tmp'

  gem = Opal::Gem.new File.dirname(__FILE__)
  content = gem.bundle :dependencies => 'ospec', :main => 'ospec/autorun', :test_files => true
  File.open('tmp/core.spec.js', 'w+') { |out| out.write content }
end

require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--title', 'Documentation for Opal Core Library',
              '--markup', 'markdown']
end



