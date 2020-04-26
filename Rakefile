# FIXME: there must be a better way
Encoding.default_external = 'utf-8'

Dir["#{__dir__}/tasks/*.rake"].each { |rakefile| import rakefile }

task :default => [:rspec, :mspec, :minitest]
