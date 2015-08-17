require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/lib/**/*_spec.rb'
end

require 'mspec/opal/rake_task'
MSpec::Opal::RakeTask.new(:mspec_phantom) do |config|
  config.pattern = ENV['MSPEC_PATTERN'] if ENV['MSPEC_PATTERN']
  config.basedir = ENV['MSPEC_BASEDIR'] if ENV['MSPEC_BASEDIR']
end

MSpec::Opal::RakeTask.new(:mspec_phantom_bignum) do |config|
  config.pattern = ENV['MSPEC_PATTERN'] if ENV['MSPEC_PATTERN']
  config.basedir = ENV['MSPEC_BASEDIR'] if ENV['MSPEC_BASEDIR']
  config.bignum = true
  config.requiers = ["require 'opal-bignum'"]
  config.inline_operators_enabled = false
end

desc <<-DESC
Run the MSpec test suite on node with tests for Bignumsupport

Use PATTERN and env var to manually set the glob for specs:

  # Will run all specs matching the specified pattern.
  # (Note: the rubyspecs filters will still apply)
  rake mspec_node PATTERN=spec/rubyspec/core/module/class_variable*
DESC
task :mspec_node_bignum do
  rubyspecs = read_rubypecs

  rubyspecs += Dir["spec/rubyspec/core/bignum/*.rb"]

  filters = Dir['spec/filters/**/*.rb', 'spec/bignum_filters/**/*.rb']
  shared = Dir['spec/{opal,lib/parser}/**/*_spec.rb'] + ['spec/lib/lexer_spec.rb']

  requires = required_specs(filters, shared, rubyspecs)
  requires.unshift("require 'opal-bignum'")
  create_and_run_file(requires, '-B')
end

desc <<-DESC
Run the MSpec test suite on node

Use PATTERN and env var to manually set the glob for specs:

  # Will run all specs matching the specified pattern.
  # (Note: the rubyspecs filters will still apply)
  rake mspec_node PATTERN=spec/rubyspec/core/module/class_variable*
DESC
task :mspec_node do
  rubyspecs = read_rubypecs

  filters = Dir['spec/filters/**/*.rb']
  shared = Dir['spec/{opal,lib/parser}/**/*_spec.rb'] + ['spec/lib/lexer_spec.rb']

  requires = required_specs(filters, shared, rubyspecs)
  create_and_run_file(requires)
end


def read_rubypecs
  excepting = []
  File.read('spec/rubyspecs').lines.reject do |l|
    l.strip!; l.start_with?('#') || l.empty? || (l.start_with?('!') && excepting.push(l.sub('!', 'spec/') + '.rb'))
  end.flat_map do |path|
    path = "spec/#{path}"
    File.directory?(path) ? Dir[path+'/*.rb'] : "#{path}.rb"
  end - excepting
end

def required_specs(filters, shared, rubyspecs)
  specs = []
  add_specs = ->(name, new_specs) { p [new_specs.size, name]; specs + new_specs}

  specs = add_specs.(:filters, filters)
  pattern = ENV['PATTERN']
  whitelist_pattern = !!ENV['RUBYSPECS']

  if pattern
    custom = Dir[pattern]
    custom &= rubyspecs if whitelist_pattern
    specs = add_specs.(:custom, custom)
  else
    specs = add_specs.(:shared, shared)
    specs = add_specs.(:rubyspecs, rubyspecs)
  end
  specs.map{|s| "require '#{s.sub(/^spec\//,'')}'"}
end

def create_and_run_file(requires, options="")

  include_paths = '-Ispec -Ilib'

  filename = 'tmp/mspec_node.rb'
  js_filename = 'tmp/mspec_node.js'
  mkdir_p File.dirname(filename)

  if ENV['BM']
    mkdir_p 'tmp/bench'
    index = 0
    begin
      index += 1
      bm_filepath = "tmp/bench/Spec#{index}"
    end while File.exist?(bm_filepath)
    enter_benchmarking_mode = "OSpecRunner.main.bm!(#{Integer(ENV['BM'])}, '#{bm_filepath}')"
  end

  File.write filename, <<-RUBY
      require 'spec_helper'
  #{enter_benchmarking_mode}
  #{requires.join("\n    ")}
      OSpecRunner.main.did_finish
  RUBY

  stubs = '-smspec/helpers/tmp -smspec/helpers/environment -smspec/guards/block_device -smspec/guards/endian'

  sh "ruby -rbundler/setup -rmspec/opal/special_calls "\
    "bin/opal #{options} -gmspec #{include_paths} #{stubs} -rnodejs/io -rnodejs/kernel -Dwarning -A #{filename} -c > #{js_filename}"
  sh "jshint --verbose #{js_filename}"
  sh "NODE_PATH=stdlib/nodejs/node_modules node #{js_filename}"

  if bm_filepath
    puts "Benchmark results have been written to #{bm_filepath}"
    puts "To view the results, run bundle exec rake bench:report"
  end
end

task :cruby_tests do
  if ENV.key? 'FILES'
    files = Dir[ENV['FILES'] || 'test/test_*.rb']
    include_paths = '-Itest -I. -Itmp -Ilib'
  else
    include_paths = '-Itest/cruby/test'
    test_dir = Pathname("#{__dir__}/../test/cruby/test")
    files = %w[
      benchmark/test_benchmark.rb
      ruby/test_call.rb
    ].flat_map do |path|
      if path.end_with?('.rb')
        path
      else
        glob = test_dir.join(path+"/test_*.rb").to_s
        size = test_dir.to_s.size
        Dir[glob].map { |file| file[size+1..-1] }
      end
    end
  end
  include_paths << ' -Ivendored-minitest'

  requires = files.map{|f| "require '#{f}'"}
  filename = 'tmp/cruby_tests.rb'
  js_filename = 'tmp/cruby_tests.js'
  mkdir_p File.dirname(filename)
  File.write filename, requires.join("\n")

  stubs = "-soptparse -sio/console -stimeout -smutex_m -srubygems -stempfile -smonitor"

  puts "== Running: #{files.join ", "}"

  sh "ruby -rbundler/setup "\
    "bin/opal #{include_paths} #{stubs} -rnodejs -Dwarning -A #{filename} -c > #{js_filename}"
  sh "NODE_PATH=stdlib/nodejs/node_modules node #{js_filename}"
end

task :mspec    => [:mspec_node, :mspec_phantom]
task :mspec_bignum    => [:mspec_node_bignum, :mspec_phantom_bignum]
task :minitest => [:cruby_tests]
task :test_all => [:rspec, :mspec, :minitest]
