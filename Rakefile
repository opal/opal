require 'bundler/setup'
require 'bundler/gem_tasks'
require 'opal'
require 'fileutils'

desc "Rebuild opal.js and opal.debug.js in runtime/"
task :opal do
  Dir.chdir "runtime" do
    puts sh("rake opal:default")
    puts sh("rake opal:debug")
  end
end
