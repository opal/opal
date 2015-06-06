if RUBY_ENGINE == 'opal'
  require 'opal/compiler'
  require 'nodejs'
end

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

  if RUBY_ENGINE == 'opal'
    code = Opal.compile(File.read(file))
    time = Benchmark.measure { `eval(code)` }
  else
    code = File.read(file)
    time = Benchmark.measure { eval(code) }
  end

  total_time += time.real
  print time.real, "\n"
end

bottom_line = "Executed #{ files.length } benchmark#{ 's' if files.length != 1} in #{ total_time } sec"
$stderr.print "=" * bottom_line.length, "\n"
$stderr.print bottom_line, "\n"
