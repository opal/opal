# FIXME: there must be a better way
Encoding.default_external = 'utf-8'

require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

import 'tasks/github.rake'
import 'tasks/documenting.rake'
import 'tasks/testing.rake'
import 'tasks/building.rake'
import 'tasks/linting.rake'

# task :default => [:rspec, :mspec_node, :cruby_tests]
# temporarily excluding :cruby_tests because ruby/test_call.rb raises
# NoMethodError: undefined method `assert_nothing_raised' for TestCall#test_callinfo
task :default => [:rspec, :mspec_node]
