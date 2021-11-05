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
    es8, es3 = files.partition { |i| i.include? "await" }

    [es3, es8].each do |files|
      config = (files == es8) ? ["-c", __dir__+"/../.eslintrc.await.js"] : []

      sh "yarn", "run", "eslint", *config, *files, "--format", "json", "--output-file", result_path do |ok, _|
        if ok
          puts "Successful."
        else
          sh 'node tasks/linting-parse-eslint-results.js'
        end
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

task :lint => %w[lint:eslint lint:rubocop]
