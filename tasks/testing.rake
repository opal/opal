require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/lib/**/*_spec.rb'
end

require 'mspec/opal/rake_task'
MSpec::Opal::RakeTask.new(:mspec_phantom) do |config|
  config.pattern = ENV['MSPEC_PATTERN'] if ENV['MSPEC_PATTERN']
  config.basedir = ENV['MSPEC_BASEDIR'] if ENV['MSPEC_BASEDIR']
end

desc <<-DESC
Run the MSpec test suite on node

Use PATTERN and env var to manually set the glob for specs:

  # Will run all specs matching the specified pattern.
  # (Note: the rubyspecs filters will still apply)
  rake mspec_node PATTERN=spec/corelib/core/module/class_variable*
DESC
task :mspec_node do
  rubyspecs = File.read('spec/rubyspecs').lines.reject do |l|
    l.strip!; l.start_with?('#') || l.empty?
  end.flat_map do |path|
    path = "spec/#{path}"
    File.directory?(path) ? Dir[path+'/*.rb'] : "#{path}.rb"
  end

  filters = Dir['spec/filters/**/*.rb']
  shared = Dir['spec/{opal,lib/parser}/**/*_spec.rb'] + ['spec/lib/lexer_spec.rb']

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

  requires = specs.map{|s| "require '#{s.sub(/^spec\//,'')}'"}
  filename = 'tmp/mspec_node.rb'
  mkdir_p File.dirname(filename)
  File.write filename, <<-RUBY
    require 'spec_helper'
    #{requires.join("    \n")}
    OSpecRunner.main.did_finish
  RUBY

  stubs = " -smspec/helpers/tmp -smspec/helpers/environment -smspec/guards/block_device -smspec/guards/endian"

  sh 'RUBYOPT="-rbundler/setup -rmspec/opal/special_calls" '\
     "bin/opal -Ispec -Ilib -gmspec #{stubs} -rnodejs -Dwarning -A #{filename}"
end

task :cruby_tests do
  if ENV.key? 'FILES'
    files = Dir[ENV['FILES'] || 'test/test_*.rb']
    include_paths = '-Itest -I. -Itmp -Ilib'
  else
    include_paths = '-Itest/cruby/test'
    test_dir = Pathname("#{__dir__}/test/cruby/test")
    files = %w[
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

  requires = files.map{|f| "require '#{f}'"}
  filename = 'tmp/cruby_tests.rb'
  mkdir_p File.dirname(filename)
  File.write filename, <<-RUBY
    #{requires.join("    \n")}
    exit
  RUBY

  stubs = "-soptparse -sio/console -stimeout -smutex_m -srubygems -stempfile -smonitor"

  puts "== Running: #{files.join ", "}"

  sh 'RUBYOPT="-rbundler/setup" '\
     "bin/opal #{include_paths} #{stubs} -rnodejs -Dwarning -A #{filename} -c > tmp/cruby_tests.js"
  sh 'node tmp/cruby_tests.js'
end

task :mspec    => [:mspec_node, :mspec_phantom]
task :test_all => [:rspec, :mspec, :cruby_tests]

