require_relative '../lib/opal/version'
require_relative '../lib/opal/cli_runners'

namespace :bench do
  directory "tmp/bench"

  report_file_for = -> name {
    index = Dir['tmp/bench/*'].map{|f| File.basename(f).to_i}.sort.last.to_i + 1
    "tmp/bench/#{index}_#{name.gsub('.', '-')}.txt"
  }

  runners = Opal::CliRunners.registered_runners.sort.reject { |r| r == 'Compiler' }
  runners.each do |runner|
    desc "Benchmark Opal with #{runner}"
    runner_dc = runner.downcase
    task_name = "opal_#{runner_dc}".to_sym
    task task_name => "tmp/bench" do |t, args|
      files = Array(args[:files]) + args.extras
      report = report_file_for["opal-#{runner_dc}-#{Opal::VERSION}"]
      sh "bundle exec ruby benchmark/run.rb --#{runner_dc} #{files.join(" ")} | tee #{report}"
    end
  end

  desc "Benchmark Ruby"
  task :ruby => "tmp/bench" do |t, args|
    files = Array(args[:files]) + args.extras
    report = report_file_for["ruby-#{RUBY_VERSION}"]
    sh "bundle exec ruby benchmark/run.rb --ruby #{files.join(" ")} | tee #{report}"
  end

  desc "Benchmark Ruby vs Opal Node"
  task :ruby_vs_opal => "tmp/bench" do |t, args|
    files = Array(args[:files]) + args.extras
    report = report_file_for["ruby-#{RUBY_VERSION}-vs-opal-node-#{Opal::VERSION}"]
    sh "bundle exec ruby benchmark/run.rb --ruby --node #{files.join(" ")} | tee #{report}"
  end

  desc "Benchmark All Engines"
  task :all => "tmp/bench" do |t, args|
    files = Array(args[:files]) + args.extras
    report = report_file_for["ruby-#{RUBY_VERSION}-vs-opal-all-#{Opal::VERSION}"]
    sh "bundle exec ruby benchmark/run.rb --ruby --node --chrome --firefox #{files.join(" ")} | tee #{report}"
  end

  desc "Delete all benchmark results"
  task :clear do
    sh "rm tmp/bench/*"
  end

  def results_to_f(results)
    ips = results.compact
    ips.each_with_index do |i, idx|
      factor = case i[-1]
               when 'G' then 1_000_000_000
               when 'M' then 1_000_000
               when 'k' then 1_000
               else
                 1
               end
      ips[idx] = (factor > 1 ? i[0..-2].to_f : i.to_f) * factor
    end
    ips
  end

  desc "Combined report of all benchmark results"
  task :report do |t, args|
    files = Array(args[:files]) + args.extras
    if files.empty?
      files = Dir["tmp/bench/*"]
    else
      files = files.map{|file| "tmp/bench/#{ file }"}
    end
    reports = []
    benchmark_names = []

    files.each do |file|
      report_name = File.basename(file, File.extname(file))
      report_results = {}
      File.read(file).each_line do |line|
        benchmark_name, benchmark_result_a, benchmark_result_b, benchmark_result_c = line.split(" ")
        if benchmark_result_b == "i/s"
          benchmark_result_b = benchmark_result_c = nil
        elsif benchmark_result_c == "i/s"
          benchmark_result_c = nil
        end
        report_results[benchmark_name] = [benchmark_result_a, benchmark_result_b, benchmark_result_c]
        benchmark_names << benchmark_name
      end
      reports << [report_name, report_results]
    end

    benchmark_names.uniq!

    header = ["Benchmark"]
    reports.each do |report_name, _|
      header << (report_name+' | ')
    end

    base_report_name, base_report_results = reports.to_a.first
    puts "Base: #{base_report_name}"

    table = [header]
    result_rows = []
    benchmark_names.each do |benchmark_name|
      row = [benchmark_name]
      reports.each do |report_name, report_results|
        results_string = ""

        if report_results[benchmark_name]
          ips = results_to_f(report_results[benchmark_name])
          base_ips = report_name != base_report_name && base_report_results[benchmark_name] ? results_to_f(base_report_results[benchmark_name]) : []

          ips.each_with_index do |i, idx|
            if base_ips[idx]
              delta_percent = -((1 - i/base_ips[idx])*100)
              results_string << format("%+0.2f%%", delta_percent).rjust(10).ljust(12)
            else
              results_string << (" "*14)
            end

            results_string << format("%0.3f i/s", i).rjust(9)
          end
        end
        results_string << ' | '
        row << results_string
      end
      result_rows << row
    end

    table += result_rows.sort_by{|row| row[2].scan(/([\+|\-]\d+\.\d+)%/).flatten.first.to_f}

    fmt = ""
    table.transpose.each_with_index do |column, index|
      column_width = column.max_by{|string| string.length}.length
      if index.zero?
        fmt << "%-#{ column_width }s"
      else
        fmt << "  %#{ column_width }s"
      end
    end
    fmt << "\n"

    table.each do |row|
      printf fmt, *row
    end
  end

  task :ips do
    files = Dir[ENV['FILE'] || "#{__dir__}/../benchmark-ips/bm_*.rb"]
    raise ArgumentError, "no files provided" if files.empty?
    puts "=== Files: #{files.join ', '}"
    files.each do |bm_path|
      sh "bundle exec opal --dynamic-require ignore --missing-require ignore -gbenchmark-ips -rbenchmark/ips -A #{bm_path}"
    end
  end
end
