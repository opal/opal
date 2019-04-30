# FIXME: there must be a better way
Encoding.default_external = 'utf-8'

import 'tasks/github.rake'
import 'tasks/testing.rake'
import 'tasks/building.rake'
import 'tasks/linting.rake'
import 'tasks/benchmarking.rake'
import 'tasks/releasing.rake'

task :default => [:rspec, :mspec, :minitest]
