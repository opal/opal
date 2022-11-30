require 'open3'
require 'optparse'
require 'opal/os'
require 'opal/cli_runners'

OS = Opal::OS

files = ARGV

# ruby exes
bench_exe = "bin/opal-bench-%{runner}#{'.bat' if OS.windows?}" # pattern for runners as ruby for benchmark_driver
ruby_exe = Gem.ruby

# runners
runners = Opal::CliRunners.registered_runners.sort.reject { |r| r == 'Compiler' }

# rubies for benchmark_driver
rubies = []

OptionParser.new do |parser|
  parser.banner = "Usage: run.rb runner(s) [files...]"
  parser.on("--ruby", "Use systme Ruby") { rubies << ruby_exe }

  runners.each do |runner|
    runner_dc = runner.downcase
    parser.on("--#{runner_dc}", "Use Opal #{runner} runner") { rubies << (bench_exe % { runner: runner_dc }) }
  end
end.parse!

# check if rubies exist
raise "No runner! Must provide at least one runner with --{runner name}, eg. --chrome or --firefox." if rubies.empty?
rubies.each do |ruby|
  raise "The #{ruby} does not exist yet. Pleas use another runner." unless File.exist?(ruby)
end

rubies = rubies.join(';')

if ENV['OPAL_BENCH_EXTRA_RUBIES']
  rubies << ';'
  rubies << ENV['OPAL_BENCH_EXTRA_RUBIES']
end

# files
if files.empty?
  files = File.read('benchmark/benchmarks').lines.map(&:strip).reject do |line|
    line.empty? || line.start_with?('#')
  end
end

files = files.shuffle

# run
files.each do |file|
  if !File.exist?(file)
    STDERR.puts "Error: #{file} does not exist!"
    next
  end
  STDERR.puts "\nBenchmarking #{file} started at #{Time.now}:"
  out, err, status = Open3.capture3("bundle exec benchmark-driver -e \"#{rubies}\" #{file}")
  if out.include?('ERROR')
    # print errors
    STDERR.puts "ERROR:\n#{err}"
  end
  # print numbers to STDOUT for tee to record
  c_idx = out.index("Calculating")
  out[c_idx..-1].each_line { |line| puts line if line.include?(' times in ') && !line.include?('ERROR')}
  # print complete output to STDERR for a nice view
  STDERR.puts out
end
STDERR.puts "\n\n" # keep this because of tee delay (Windows)
