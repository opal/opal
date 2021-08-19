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
  change = ((current - previous).to_f / previous) * 100 

  puts ("%30s: %.3f -> %.3f (change: %.2f%%)" % [name, previous, current, change]).gsub('.000','')

  if change > 5.0
    failure.("#{name} increased by more than 5%")
  end
end

task :asciidoctor_prepare do
  # Selected asciidoctor versions were working on Aug 19 2021, feel free to update.
  system("bash", "-c", <<~END)
    mkdir -p tmp/performance
    pushd tmp/performance
    git clone https://github.com/asciidoctor/asciidoctor >/dev/null 2>&1
    pushd asciidoctor; git checkout 869e8236 >/dev/null 2>&1; popd
    git clone https://github.com/asciidoctor/asciidoctor.js >/dev/null 2>&1
    pushd asciidoctor.js; git checkout 053fa0d3 >/dev/null 2>&1; popd
    erb ../../tasks/performance/asciidoctor_test.rb.erb > asciidoctor_test.rb
    popd
  END
end

task :asciidoctor_build_opal do
  system("bin/opal -c" \
           "-Itmp/performance/asciidoctor/lib " \
           "-Itmp/performance/asciidoctor.js/packages/core/lib " \
           "tmp/performance/asciidoctor_test.rb > tmp/performance/asciidoctor_test.js")
end

task :asciidoctor_run_ruby do
  system("ruby -Itmp/performance/asciidoctor/lib tmp/performance/asciidoctor_test.rb")
end

task :asciidoctor_run_opal do
  system("node tmp/performance/asciidoctor_test.js")
end

desc "Generate V8 function optimization status report for corelib methods"
task :optstatus do
  system("NODE_OPTS=--allow-natives-syntax bin/opal tasks/performance/optimization_status.rb")
end

task :performance_compare do
  this_ref = `git describe --tags`.chomp
  ref = 'master'
  ref = ENV['GITHUB_BASE_REF'] if ENV['GITHUB_BASE_REF'] && !ENV['GITHUB_BASE_REF'].empty?

  # Prepare
  system("bundle exec rake asciidoctor_prepare")
  system("bundle exec rake asciidoctor_run_ruby > tmp/performance/ruby_result.html")

  # Run on current
  puts "* Checking optimization status with current..."
  system("bundle exec rake optstatus > tmp/performance/optstatus_current")
  puts "* Building AsciiDoctor with current..."
  compiler_time_current = mean_time.(tries: 7) do
    system("bundle exec rake asciidoctor_build_opal")
  end
  puts "* Running AsciiDoctor with current..."
  run_time_current = mean_time.(tries: 31) do
    system("bundle exec rake asciidoctor_run_opal > tmp/performance/opal_result_current.html")
  end
  correct_current = File.read("tmp/performance/opal_result_current.html") == File.read("tmp/performance/ruby_result.html")
  size_current = File.size("tmp/performance/asciidoctor_test.js")
  puts "* Minifying AsciiDoctor with current..."
  min_size_current = Opal::Util.uglify(File.read("tmp/performance/asciidoctor_test.js")).bytesize rescue 133799999999999

  # Prepare previous
  system("git checkout --recurse-submodules #{ref}")
  system("bundle install >/dev/null 2>&1")

  # Run on previous
  puts "* Checking optimization status with previous..."
  system("bundle exec rake optstatus > tmp/performance/optstatus_previous")
  puts "* Building AsciiDoctor with previous..."
  compiler_time_previous = mean_time.(tries: 7) do
    system("bundle exec rake asciidoctor_build_opal")
  end
  puts "* Running AsciiDoctor with previous..."
  run_time_previous = mean_time.(tries: 31) do
    system("bundle exec rake asciidoctor_run_opal > tmp/performance/opal_result_previous.html")
  end
  correct_previous = File.read("tmp/performance/opal_result_previous.html") == File.read("tmp/performance/ruby_result.html")
  size_previous = File.size("tmp/performance/asciidoctor_test.js")
  puts "* Minifying AsciiDoctor with previous..."
  min_size_previous = Opal::Util.uglify(File.read("tmp/performance/asciidoctor_test.js")).bytesize rescue 133799999999999

  # Restore current
  system("git checkout --recurse-submodules #{this_ref}")
  system("bundle install >/dev/null 2>&1")

  # Summary
  puts
  puts "Summary of performance changes between (previous) #{ref} and (current) #{this_ref}:"

  diff = `diff -F '^Class' -Naur tmp/performance/optstatus_previous tmp/performance/optstatus_current`
  diff_lines = diff.split("\n")

  puts
  puts "Comparison of V8 function optimization status:"
  puts diff

  if diff_lines.grep(/^-\s+\[COMPILED\]/).count > 0
    failure.("Some methods are no longer compiled on V8")
  end

  puts
  puts "Comparison of the Asciidoctor (a real-life Opal application) compile and run:"

  failure.("Wrong result on the current branch") unless correct_current
  failure.("Wrong result on the previous branch - ignore it") unless correct_previous

  compare_values.("Compile time",        compiler_time_current, compiler_time_previous)
  compare_values.("Run time",                 run_time_current,      run_time_previous)
  compare_values.("Bundle size",                  size_current,          size_previous)
  compare_values.("Minified bundle size",     min_size_current,      min_size_previous)

  if failed
    puts
    puts "This run failed - some performance checks did not pass. Don't worry, this is"
    puts "informative, not fatal. It may be worth to rerun the task or consult those"
    puts "results with a pull request reviewer:"
    failed.each do |f|
      puts " - #{f}"
    end
    fail
  end
end
