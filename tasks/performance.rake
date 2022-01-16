# A set of tasks to track performance regressions by the CI

require 'opal/util'

class Timing
  def initialize(tries: 31, &block)
    @tries = tries
    @times = tries.times.map do
      t = now
      block.()
      (now - t)
    end.sort
  end

  def now
    Process.clock_gettime Process::CLOCK_MONOTONIC, :float_microsecond
  end

  attr_reader :times, :tries

  # Runs a block N times and returns a mean number of seconds it took to run it.
  def mean_time
    @times.sort[tries/2.0.floor + 1]
  end

  def error
    m = mean_time
    @times.minmax.map { |t| (m - t).abs }.max
  end

  def compare_to(previous, name)
    current = self
    percent = ->(a, b) { (a / b) * 100 }
    change = percent[(current.mean_time - previous.mean_time), previous.mean_time]

    puts ("%30s: %.3f (±%.2f%%) -> %.3f (±%.2f%%) (change: %+.2f%%)" % [
      name,
      previous.mean_time / 1_000_000.0, percent[previous.error, previous.mean_time],
      current.mean_time / 1_000_000.0, percent[current.error, current.mean_time],
      change
    ]).gsub('.000','')

    $failures << "#{name} increased by more than 5%" if change > 5.0
  end
end

class Size
  def initialize(size)
    @size = size
  end

  attr_reader :size

  def compare_to(previous, name)
    change = 100 * (previous.size - size) / previous.size
    puts ("%30s: %5.2f kB -> %5.2f kB (change: %+.2f%%)" % [
      name,
      previous.size / 1_000.0,
      size / 1_000.0,
      change,
    ])

    $failures << "#{name} increased by more than 5%" if change > 5.0
  end
end

$failures = []

ASCIIDOCTOR_REPO_BASE = ENV['ASCIIDOCTOR_REPO_BASE'] || 'https://github.com/asciidoctor'

# Selected asciidoctor versions were working on Aug 19 2021, feel free to update.
ASCIIDOCTOR_PREPARE = [
  "bundle",
  "exec",
  "bash",
  "-c",
  <<~BASH
    mkdir -p tmp/performance
    pushd tmp/performance
    git clone #{ASCIIDOCTOR_REPO_BASE}/asciidoctor >/dev/null 2>&1
    pushd asciidoctor; git checkout 869e8236 >/dev/null 2>&1; popd
    git clone #{ASCIIDOCTOR_REPO_BASE}/asciidoctor.js >/dev/null 2>&1
    pushd asciidoctor.js; git checkout 053fa0d3 >/dev/null 2>&1; popd
    erb ../../tasks/performance/asciidoctor_test.rb.erb > asciidoctor_test.rb
    popd
  BASH
]

ASCIIDOCTOR_BUILD_OPAL = "bin/opal --no-cache -c " \
           "-Itmp/performance/asciidoctor/lib " \
           "-Itmp/performance/asciidoctor.js/packages/core/lib " \
           "-sconcurrent/map -sslim/include " \
           "tmp/performance/asciidoctor_test.rb > tmp/performance/asciidoctor_test.js"
ASCIIDOCTOR_RUN_RUBY = "bundle exec ruby -Itmp/performance/asciidoctor/lib tmp/performance/asciidoctor_test.rb"
ASCIIDOCTOR_RUN_OPAL = "node tmp/performance/asciidoctor_test.js"

# Generate V8 function optimization status report for corelib methods
NODE_OPTSTATUS = "env NODE_OPTS=--allow-natives-syntax bin/opal tasks/performance/optimization_status.rb"

performance_stat = ->(name) {
  stat = {}

  # Run on current
  puts "\n* Checking optimization status with #{name}..."
  sh("#{NODE_OPTSTATUS} > tmp/performance/optstatus_#{name}")

  puts "\n* Building AsciiDoctor with #{name}..."
  stat[:compiler_time] = Timing.new(tries: 7) { sh(ASCIIDOCTOR_BUILD_OPAL) }

  puts "\n* Running AsciiDoctor with #{name}..."
  stat[:run_time] = Timing.new(tries: 63) { sh("#{ASCIIDOCTOR_RUN_OPAL} > tmp/performance/opal_result_#{name}.html") }
  stat[:correct] = File.read("tmp/performance/opal_result_#{name}.html") == File.read("tmp/performance/ruby_result.html")
  stat[:size] = Size.new File.size("tmp/performance/asciidoctor_test.js")

  puts "\n* Minifying AsciiDoctor with #{name}..."
  source = File.read("tmp/performance/asciidoctor_test.js")
  stat[:min_size] = Size.new Opal::Util.uglify(source).bytesize rescue Float::INFINITY
  stat[:min_size_m] = Size.new Opal::Util.uglify(source, mangle: true).bytesize rescue Float::INFINITY

  stat
}

namespace :performance do
  task :compare do
    this_ref = `git describe --tags`.chomp
    ref = 'master'
    ref = ENV['GITHUB_BASE_REF'] if ENV['GITHUB_BASE_REF'] && !ENV['GITHUB_BASE_REF'].empty?

    # Prepare
    puts "\n* Preparing asciidoctor..."
    sh(*ASCIIDOCTOR_PREPARE)

    puts "\n* Running AsciiDoctor with CRuby..."
    sh("#{ASCIIDOCTOR_RUN_RUBY} > tmp/performance/ruby_result.html")

    current = performance_stat.(:current)

    # Prepare previous
    sh("git checkout --recurse-submodules #{ref} && bundle install >/dev/null 2>&1")

    previous = performance_stat.(:previous)

    # Restore current
    sh("git checkout --recurse-submodules - && bundle install >/dev/null 2>&1")

    # Summary
    puts "\n=== Summary ==="
    puts "Summary of performance changes between (previous) #{ref} and (current) #{this_ref}:"

    diff = `diff --report-identical-files -F '^Class' -Naur tmp/performance/optstatus_previous tmp/performance/optstatus_current`
    diff_lines = diff.split("\n")

    puts
    puts "Comparison of V8 function optimization status:"
    puts diff

    if diff_lines.grep(/^-\s+\[COMPILED\]/).count > 0
      failure.("Some methods are no longer compiled on V8")
    end

    puts
    puts "Comparison of the Asciidoctor (a real-life Opal application) compile and run:"

    failure.("Wrong result on the current branch") unless current[:correct]
    failure.("Wrong result on the previous branch - ignore it") unless previous[:correct]

    current[:compiler_time].compare_to(previous[:compiler_time], "Compile time")
    current[:run_time     ].compare_to(previous[:run_time     ], "Run time")
    current[:size         ].compare_to(previous[:size         ], "Bundle size")
    current[:min_size     ].compare_to(previous[:min_size     ], "Minified bundle size")
    current[:min_size_m   ].compare_to(previous[:min_size_m   ], "Mangled & minified")

    if $failures.any?
      puts "--- Failures ---"
      $failures.each do |f|
        puts " - #{f}"
      end
      puts
      puts "This run failed - some performance checks did not pass. Don't worry, this is"
      puts "informative, not fatal. It may be worth to rerun the task, rebase the branch,"
      puts "or consult those results with a pull request reviewer."
      fail
    end
  end
end

task :performance => ['performance:compare']
