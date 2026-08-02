import 'tasks/building.rake'


namespace :lint do
  desc "Build *corelib* and *stdlib* and lint the result"
  task :eslint do
    require 'json'
    require 'pathname'

    result_path = "tmp/lint/result.json"
    dir = ENV['DIR'] ||= 'tmp/lint'
    ENV['FORMATS'] = 'js,map'
    rm_rf dir if File.exist? dir

    Rake::Task[:dist].invoke

    files = Dir["#{dir}/*.js"]

    unless File.exist?('node_modules/.bin/eslint')
      abort 'ESLint is not installed. Run `bin/setup` (or `bin/yarn install`) first.'
    end

    # NOTE: go through bin/yarn rather than a bare `yarn` so the Yarn v1 resolution
    # (and its npx fallback) in that script applies here too.
    sh "bin/yarn", "run", "eslint", *files, "--format", "json", "--output-file", result_path do |ok, _|
      if ok
        puts "Successful."
      else
        sh 'node tasks/linting-parse-eslint-results.js'
      end
    end
  end
end

require 'rubocop/rake_task'
desc 'Run RuboCop on lib/, opal/ and stdlib/ directories'
RuboCop::RakeTask.new('lint:rubocop') do |task|
  task.options << '--extra-details'
  task.options << '--display-style-guide'
  task.options << '--parallel'
end

desc 'Run all linters (ESLint on the built dist, RuboCop on lib/, opal/ and stdlib/)'
task :lint => %w[lint:eslint lint:rubocop]
