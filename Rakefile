# FIXME: there must be a better way
Encoding.default_external = 'utf-8'

require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

import 'tasks/github.rake'
import 'tasks/testing.rake'
import 'tasks/building.rake'
import 'tasks/linting.rake'
import 'tasks/benchmarking.rake'

task :default => [:rspec, :mspec_nodejs, :cruby_tests]
