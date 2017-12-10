if RUBY_ENGINE == 'opal'
  require 'opal/compiler'
  require 'nodejs'
end

BEST_OF_N = Integer(ENV['BEST_OF_N']) rescue 1

require 'benchmark'

files = ARGV

if files.empty?
  files = File.read('benchmark/benchmarks').lines.map(&:strip).reject do |line|
    line.empty? || line.start_with?('#')
  end
end

maxlen = files.max_by{|file| file.length}.length + 1

total_time = 0

files.each do |file|
  print file, " " * (maxlen - file.length)

  times = []

  if RUBY_ENGINE == 'opal'
    code = File.read(file)
    code = "Benchmark.measure { #{code} }"
    code = Opal.compile(code, file: file)

    BEST_OF_N.times do
      times << `eval(code)`
    end
  else
    code = File.read(file)
    code = "Benchmark.measure { #{code} }"

    BEST_OF_N.times do
      times << eval(code)
    end
  end

  time = times.min_by{|t| t.real}

  total_time += time.real

  print time.real, "\n"
end

bottom_line = "Executed #{ files.length } benchmark#{ 's' if files.length != 1} in #{ total_time } sec"
$stderr.print "=" * bottom_line.length, "\n"
$stderr.print bottom_line, "\n"
