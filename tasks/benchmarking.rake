namespace :bench do
  directory "tmp/bench"

  desc "Benchmark Opal"
  task :opal => "tmp/bench" do |t, args|
    files = Array(args[:files]) + args.extras
    index = 0
    begin
      index += 1
      report = "tmp/bench/Opal#{index}"
    end while File.exist?(report)
    sh "bundle exec opal benchmark/run.rb #{files.join(" ")} | tee #{report}"
  end

  desc "Benchmark Ruby"
  task :ruby => "tmp/bench" do |t, args|
    files = Array(args[:files]) + args.extras
    index = 0
    begin
      index += 1
      report = "tmp/bench/Ruby#{index}"
    end while File.exist?(report)
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
      header << report_name
    end

    table = [header]
    benchmark_names.each do |benchmark_name|
      row = [benchmark_name]
      reports.each do |_, report_results|
        if report_results[benchmark_name]
          row << format("%0.3f", report_results[benchmark_name])
        else
          row << ""
        end
      end
      table << row
    end

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
end
