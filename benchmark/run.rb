require 'opal/compiler'
require 'benchmark'
require 'nodejs'

files = ARGV

if files.empty?
  files = File.read('benchmark/benchmarks').lines.map(&:strip).reject do |line|
    line.empty? || line.start_with?('#')
  end
end

maxlen = files.max_by{|file| file.length}.length + 1

total_time = Benchmark.measure do
  files.each do |file|
    print file, " " * (maxlen - file.length)
    code = Opal.compile(File.read(file))
    time = Benchmark.measure do
      `eval(code)`
    end
    print time, "\n"
  end
end

bottom_line = "Executed #{ files.length } benchmark#{ 's' if files.length != 1} in #{ total_time } sec"
print "=" * bottom_line.length, "\n"
print bottom_line, "\n"
