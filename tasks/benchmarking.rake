namespace :bench do
  directory "tmp/bench"

  report_file_for = -> name {
    index = Dir['tmp/bench/*'].map{|f| File.basename(f).to_i}.sort.last.to_i + 1
    "tmp/bench/#{index}_#{name.gsub('.', '-')}.txt"
  }

  desc "Benchmark Opal"
  task :opal => "tmp/bench" do |t, args|
    require 'opal/version'
    files = Array(args[:files]) + args.extras
    report = report_file_for["opal-#{Opal::VERSION}"]
    sh "bundle exec opal benchmark/run.rb #{files.join(" ")} | tee #{report}"
  end

  desc "Benchmark Opal"
  task :opal_strict => "tmp/bench" do |t, args|
    require 'opal/version'
    files = Array(args[:files]) + args.extras
    report = report_file_for["opal-#{Opal::VERSION}"]
    sh "bundle exec opal -R strictnodejs benchmark/run.rb #{files.join(" ")} | tee #{report}"
  end

  desc "Benchmark Ruby"
  task :ruby => "tmp/bench" do |t, args|
    files = Array(args[:files]) + args.extras
    report = report_file_for["ruby-#{RUBY_VERSION}"]
    sh "bundle exec ruby benchmark/run.rb #{files.join(" ")} | tee #{report}"
  end

  desc "Delete all benchmark results"
  task :clear do
    sh "rm tmp/bench/*"
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
        benchmark_name, benchmark_result = line.split(" ")
        report_results[benchmark_name] = benchmark_result
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
          sec = report_results[benchmark_name].to_f

          if report_name != base_report_name && base_report_results[benchmark_name]
            base_sec = base_report_results[benchmark_name].to_f
            delta_percent = -((1 - sec/base_sec)*100)
            results_string << format("%+0.2f%%", delta_percent).rjust(10).ljust(12)
          else
            results_string << (" "*14)
          end

          results_string << format("%0.3fms", sec).rjust(9)
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
    files = Dir[ENV['FILE'] || "#{__dir__}/benchmark-ips/bm_*.rb"]
    raise ArgumentError, "no files provided" if files.empty?
    puts "=== Files: #{files.join ', '}"
    files.each do |bm_path|
      sh "bundle exec opal --dynamic-require ignore --missing-require ignore -ropal/platform -gbenchmark-ips -rbenchmark/ips -A #{bm_path}"
    end
  end
end
