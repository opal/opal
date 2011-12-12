require 'bundler/gem_tasks'
require 'opal'
require 'opal/builder_task'
require 'fileutils'

desc "Rebuild opal.js and opal.debug.js in runtime/"
task :opal do
  Dir.chdir "runtime" do
    puts sh("rake opal")
    puts sh("rake opal_debug")
  end
end