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

    sh "yarn", "run", "eslint", *Dir["#{dir}/*.js"], "--format", "json", "--output-file", result_path do |ok, _|
      if ok
        puts "Successful."
      else
        sh 'node tasks/linting-parse-eslint-results.js'
        # results = JSON.parse File.read(result_path), symbolize_names: true
        # results.each do |data|
        #   next if data[:messages].empty?
        #
        #   relative_path = Pathname(data[:filePath]).relative_path_from(Pathname(dir).expand_path)
        #   puts "* #{relative_path}"
        #   data[:messages].each do |message|
        #     puts "  - #{relative_path}:#{message[:line]}:#{message[:column]}-#{message[:endLine]}:#{message[:endColumn]} #{message[:message]}"
        #   end
        # end
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
