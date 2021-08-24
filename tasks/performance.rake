# A set of tasks to track performance regressions by the CI

require 'opal/util'

# Runs a block N times and returns a mean number of seconds it took to run it.
mean_time = proc do |tries: 31, &block|
  tries.times.map do
    t = Time.now
    block.()
    Time.now - t
  end.sort[tries/2]
end

failed = false

# Mark a failure
failure = proc do |reason|
  failed ||= []
  failed << reason
end

compare_values = proc do |name, current, previous|
  current = current.to_f
  previous = previous.to_f

  change = ((current - previous).to_f / previous) * 100

  puts ("%30s: %.3f -> %.3f (change: %+.2f%%)" % [name, previous, current, change]).gsub('.000','')

  if change > 5.0
    failure.("#{name} increased by more than 5%")
  end
end

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

ASCIIDOCTOR_BUILD_OPAL = "bin/opal -c " \
           "-Itmp/performance/asciidoctor/lib " \
           "-Itmp/performance/asciidoctor.js/packages/core/lib " \
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
  stat[:compiler_time] = mean_time.(tries: 3) { sh(ASCIIDOCTOR_BUILD_OPAL) }

  puts "\n* Running AsciiDoctor with #{name}..."
  stat[:run_time] = mean_time.(tries: 31) { sh("#{ASCIIDOCTOR_RUN_OPAL} > tmp/performance/opal_result_#{name}.html") }
  stat[:correct] = File.read("tmp/performance/opal_result_#{name}.html") == File.read("tmp/performance/ruby_result.html")
  stat[:size] = File.size("tmp/performance/asciidoctor_test.js")

  puts "\n* Minifying AsciiDoctor with #{name}..."
  stat[:min_size] = Opal::Util.uglify(File.read("tmp/performance/asciidoctor_test.js")).bytesize rescue Float::INFINITY

  stat
}

task :performance_compare do
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

  compare_values.("Compile time",        current[:compiler_time], previous[:compiler_time])
  compare_values.("Run time",                 current[:run_time],      previous[:run_time])
  compare_values.("Bundle size",                  current[:size],          previous[:size])
  compare_values.("Minified bundle size",     current[:min_size],      previous[:min_size])

  if failed
    puts
    puts "This run failed - some performance checks did not pass. Don't worry, this is"
    puts "informative, not fatal. It may be worth to rerun the task, rebase the branch,"
    puts "or consult those results with a pull request reviewer:"
    failed.each do |f|
      puts " - #{f}"
    end
    fail
  end
end
