# FIXME: there must be a better way
Encoding.default_external = 'utf-8'

require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

import 'tasks/github.rake'
import 'tasks/documenting.rake'
import 'tasks/testing.rake'
import 'tasks/building.rake'

task :default => [:rspec, :mspec_node]
