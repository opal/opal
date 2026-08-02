require 'lib/spec_helper'
require 'opal/os'
require 'opal/builder'
require 'opal/builder/scheduler/sequential'
require 'opal/builder/scheduler/threaded'
require 'tmpdir'

RSpec.describe Opal::Builder do
  subject(:builder) { described_class.new(options) }
  let(:builder_with_paths) { builder.append_paths(File.expand_path('..', __FILE__)); builder }
  let(:options) { {} }
  let(:ruby_processor) { Opal::Builder::Processor::RubyProcessor }

  def temporarily_with_prefork_scheduler(&block)
    previous = Opal.builder_scheduler
    Opal.builder_scheduler = Opal::Builder::Scheduler::Prefork
    yield
    Opal.builder_scheduler = previous
  end

  def temporarily_with_sequential_scheduler(&block)
    previous = Opal.builder_scheduler
    Opal.builder_scheduler = Opal::Builder::Scheduler::Sequential
    yield
    Opal.builder_scheduler = previous
  end

  def temporarily_with_threaded_scheduler(&block)
    previous = Opal.builder_scheduler
    Opal.builder_scheduler = Opal::Builder::Scheduler::Threaded
    yield
    Opal.builder_scheduler = previous
  end

  it 'compiles opal' do
    expect(builder.build('opal').to_s).to match('(Opal);')
  end

  it 'respect #require_tree calls' do
    expect(builder_with_paths.build('fixtures/require_tree_test').to_s).to include('Opal.modules["fixtures/required_tree_test/required_file1"]')
  end

  describe 'requires with a leading ./' do
    # Without a #cwd a leading './' is looked up in the load path. Either way
    # the module is emitted under the same key, since `Compiler.module_name`
    # cleanpaths './foo' to 'foo' and the runtime's `Opal.normalize` strips the
    # './' too. See https://github.com/opal/opal/issues/778
    it 'resolves them through the load path' do
      source = 'require "./fixtures/dot_slash_required_file"'

      expect(builder_with_paths.build_str(source, 'bar.rb').to_s)
        .to include('Opal.modules["fixtures/dot_slash_required_file"]')
    end

    it 'resolves them when the extension is given' do
      source = 'require "./fixtures/dot_slash_required_file.rb"'

      expect(builder_with_paths.build_str(source, 'bar.rb').to_s)
        .to include('Opal.modules["fixtures/dot_slash_required_file"]')
    end

    # With no cwd set there is nothing to be relative to, so a build must not
    # depend on the directory the compiler happens to run from.
    it 'resolves them through the load path, not the current working directory' do
      source = 'require "./fixtures/dot_slash_required_file"'

      output = Dir.chdir(Dir.tmpdir) { builder_with_paths.build_str(source, 'bar.rb').to_s }

      expect(output).to include('Opal.modules["fixtures/dot_slash_required_file"]')
    end

    it 'emits the module only once however the require is spelled' do
      source = <<~RUBY
        require "fixtures/dot_slash_required_file"
        require "./fixtures/dot_slash_required_file"
        require "./fixtures/dot_slash_required_file.rb"
        require "fixtures/dot_slash_required_file.rb"
      RUBY

      output = builder_with_paths.build_str(source, 'bar.rb').to_s

      expect(output.scan('Opal.modules["fixtures/dot_slash_required_file"] =').size).to eq(1)
    end

    # A './' require is never resolved against the requiring file's own
    # directory: without a cwd it is a load path lookup, with one it is
    # relative to that cwd. MRI resolves against the process CWD, so it would
    # not pick the sibling either. `require_relative` is the way to reach one.
    it 'does not resolve them relative to the requiring file' do
      source = 'require "fixtures/dot_slash_nested/dot_slash_requirer"'

      expect { builder_with_paths.build_str(source, 'bar.rb') }
        .to raise_error(Opal::Builder::MissingRequire, /dot_slash_sibling/)
    end

    # Each scheduler keeps its own dedupe bookkeeping, so they all need to agree
    # on the require key.
    describe 'deduplication across schedulers' do
      let(:source) do
        <<~RUBY
          require "fixtures/dot_slash_required_file"
          require "./fixtures/dot_slash_required_file"
          require "./fixtures/dot_slash_required_file.rb"
        RUBY
      end

      def emitted_modules_count
        my_builder = builder_with_paths.dup
        my_builder.cache = Opal::Cache::NullCache.new
        my_builder.build_str(source, 'bar.rb').to_s
          .scan('Opal.modules["fixtures/dot_slash_required_file"] =').size
      end

      it 'emits the module once with a sequential scheduler' do
        temporarily_with_sequential_scheduler do
          expect(emitted_modules_count).to eq(1)
        end
      end

      it 'emits the module once with a threaded scheduler' do
        temporarily_with_threaded_scheduler do
          expect(emitted_modules_count).to eq(1)
        end
      end

      it 'emits the module once with a prefork scheduler' do
        skip "Scheduler::Prefork not available for #{RUBY_ENGINE}" if %w[jruby truffleruby].include?(RUBY_ENGINE)
        skip "Scheduler::Prefork not available on Windows" if Opal::OS.windows?
        temporarily_with_prefork_scheduler do
          expect(emitted_modules_count).to eq(1)
        end
      end
    end
  end

  describe '#cwd' do
    around { |example| Dir.mktmpdir { |dir| @cwd = dir; example.run } }

    let(:cwd) { @cwd }

    before { File.write(File.join(cwd, 'in_cwd.rb'), 'IN_CWD = true') }

    it 'defaults to nil, leaving requires to the load path' do
      expect(builder.cwd).to be_nil
    end

    context 'when set' do
      let(:options) { {cwd: @cwd} }

      # The property is applied before the default path reader is built, so
      # this also pins that it reaches the reader rather than being dropped.
      it 'reaches the path reader' do
        expect(builder.path_reader.cwd).to eq(cwd)
      end

      it 'is carried over to copies' do
        expect(builder.dup.cwd).to eq(cwd)
      end

      # The point of the whole property: MRI resolves './foo' against the CWD.
      it 'resolves a ./ require against it, without a matching load path entry' do
        expect(builder.build_str('require "./in_cwd"', 'bar.rb').to_s)
          .to include('Opal.modules["in_cwd"]')
      end

      # The module key comes from the require string, not from where the file
      # was found, so it still matches what the runtime looks up.
      it 'emits it under the same key the runtime normalizes ./ to' do
        expect(Opal::Compiler.module_name('./in_cwd')).to eq('in_cwd')
      end

      it 'still resolves other requires through the load path' do
        expect(builder_with_paths.build_str('require "fixtures/dot_slash_required_file"', 'bar.rb').to_s)
          .to include('Opal.modules["fixtures/dot_slash_required_file"]')
      end
    end

    context 'when set through the writer' do
      it 'reaches the path reader' do
        builder.cwd = cwd

        expect(builder.path_reader.cwd).to eq(cwd)
      end
    end

    # The path reader does the resolving, so one swapped in afterwards has to
    # be told about the cwd too, or requires would quietly stop resolving.
    context 'when the path reader is replaced' do
      let(:options) { {cwd: @cwd} }

      it 'carries the cwd over to the new one' do
        builder.path_reader = Opal::PathReader.new

        expect(builder.path_reader.cwd).to eq(cwd)
      end

      it 'leaves the reader alone when there is no cwd to carry over' do
        builder = described_class.new
        builder.path_reader = Opal::PathReader.new(Opal.paths, Opal::PathReader::DEFAULT_EXTENSIONS, cwd: cwd)

        expect(builder.path_reader.cwd).to eq(cwd)
      end
    end
  end

  describe ':stubs' do
    let(:options) { {stubs: ['foo']} }

    around(:each) { |example| temporarily_with_sequential_scheduler(&example) }

    it 'compiles them as empty files' do
      source = 'require "foo"'
      expect(ruby_processor).to receive('new').with(source, anything, anything, anything).once.and_call_original
      expect(ruby_processor).to receive('new').with('',     anything, anything, anything).once.and_call_original

      builder.build_str(source, 'bar.rb')
    end
  end

  describe 'dup' do
    it 'duplicates internal structures' do
      b2 = builder.dup
      b2.should_not equal(builder)
      [:stubs, :processors, :path_reader, :compiler_options, :processed].each do |m|
        b2.send(m).should_not equal(builder.send(m))
      end
    end

    it 'processes dependencies correctly' do
      b2 = builder
      2.times do
        b2 = b2.dup
        source = 'require "json"'
        b2.build_str(source, 'bar.rb')
        b2.to_s.should include("$to_json")
      end
    end
  end

  describe 'requiring a native .js file' do
    it 'can be required without specifying extension' do
      builder_with_paths.build_str('require "fixtures/required_file"', 'foo')
      expect(builder_with_paths.to_s).to include("console.log('required file');")
    end

    it 'can be required specifying extension' do
      builder_with_paths.build_str('require "fixtures/required_file.js"', 'foo')
      expect(builder_with_paths.to_s).to include("console.log('required file');")
    end
  end

  it 'defaults config from Opal::Config' do
    Opal::Config.arity_check_enabled = false
    expect(Opal::Config.arity_check_enabled).to eq(false)
    expect(Opal::Config.compiler_options[:arity_check]).to eq(false)
    builder = described_class.new
    builder.build_str('def foo; end', 'foo')
    expect(builder.to_s).not_to include('$$parameters: []')

    Opal::Config.arity_check_enabled = true
    expect(Opal::Config.arity_check_enabled).to eq(true)
    expect(Opal::Config.compiler_options[:arity_check]).to eq(true)
    builder = described_class.new
    builder.build_str('def foo; end', 'foo')
    expect(builder.to_s).to include('$$parameters: []')
  end

  describe '#missing_require_severity' do
    around(:each) { |example| temporarily_with_sequential_scheduler(&example) }

    it 'defaults to warning' do
      expect(builder.missing_require_severity).to eq(:error)
    end

    context 'when set to :warning' do
      let(:options) { {missing_require_severity: :warning} }
      it 'warns the user' do
        expect(builder.missing_require_severity).to eq(:warning)
        expect(builder).to receive(:warn) { |message| expect(message).to start_with(%{Warning: can't find file: "non-existen-file"}) }.at_least(1)
        builder.build_str("require 'non-existen-file'", 'foo.rb')
      end
    end

    context 'when set to :ignore' do
      let(:options) { {missing_require_severity: :ignore} }
      it 'does nothing' do
        expect(builder.missing_require_severity).to eq(:ignore)
        expect(builder).not_to receive(:warn)
        expect{ builder.build_str("require 'non-existen-file'", 'foo.rb') }.not_to raise_error
      end
    end

    context 'when set to :error' do
      let(:options) { {missing_require_severity: :error} }
      it 'raises MissingRequire' do
        expect(builder.missing_require_severity).to eq(:error)
        expect(builder).not_to receive(:warn)
        expect{ builder.build_str("require 'non-existen-file'", 'foo.rb') }.to raise_error(described_class::MissingRequire)
      end
    end
  end

  describe ':requirable' do
    it 'it uses relative paths as module names' do
      expect(builder.build('stringio', requirable: true).to_s).to include(%{Opal.modules["stringio"]})
    end
  end

  describe ':requirable' do
    it 'it uses front slash as module name' do
      expect(builder.build('opal/platform', requirable: true).to_s).to include(%{Opal.modules["opal/platform"]})
    end
  end

  describe 'output order' do
    it 'is preserved with a prefork scheduler' do
      skip "Scheduler::Prefork not available for #{RUBY_ENGINE}" if %w[jruby truffleruby].include?(RUBY_ENGINE)
      skip "Scheduler::Prefork not available on Windows" if Opal::OS.windows?
      temporarily_with_prefork_scheduler do
        my_builder = builder_with_paths.dup
        my_builder.cache = Opal::Cache::NullCache.new
        10.times do |i| # Increase entropy
          expect(
            my_builder.dup.build('fixtures/build_order').to_s.scan(/(FILE_[0-9]+)/).map(&:first)
          ).to eq(%w[
            FILE_1 FILE_2 FILE_3 FILE_4
            FILE_51 FILE_5
            FILE_61 FILE_62 FILE_63 FILE_64 FILE_6
            FILE_7
          ])
        end
      end
    end

    it 'is preserved with a sequential scheduler' do
      temporarily_with_sequential_scheduler do
        expect(
          builder_with_paths.build('fixtures/build_order').to_s.scan(/(FILE_[0-9]+)/).map(&:first)
        ).to eq(%w[
          FILE_1 FILE_2 FILE_3 FILE_4
          FILE_51 FILE_5
          FILE_61 FILE_62 FILE_63 FILE_64 FILE_6
          FILE_7
        ])
      end
    end

    it 'is preserved with a threaded scheduler' do
      skip 'Scheduler::Threaded is only available for JRuby, TruffleRuby' unless %w[jruby truffleruby].include?(RUBY_ENGINE)
      temporarily_with_threaded_scheduler do
        expect(
          builder_with_paths.build('fixtures/build_order').to_s.scan(/(FILE_[0-9]+)/).map(&:first)
        ).to eq(%w[
          FILE_1 FILE_2 FILE_3 FILE_4
          FILE_51 FILE_5
          FILE_61 FILE_62 FILE_63 FILE_64 FILE_6
          FILE_7
        ])
      end
    end
  end

  # Each scheduler builds its own MissingRequire, so they all have to report
  # which file was missing. The threaded scheduler is only the default on JRuby
  # and TruffleRuby, but it runs fine on CRuby, so these are not skipped there:
  # that is the only way CI covers the branch at all.
  describe 'reporting a missing require' do
    def expect_missing_require_naming_the_file
      expect { builder_with_paths.build('fixtures/missing_require_test') }
        .to raise_error(Opal::Builder::MissingRequire, /this_file_does_not_exist/)
    end

    it 'names the missing file with a sequential scheduler' do
      temporarily_with_sequential_scheduler { expect_missing_require_naming_the_file }
    end

    it 'names the missing file with a threaded scheduler' do
      temporarily_with_threaded_scheduler { expect_missing_require_naming_the_file }
    end

    it 'names the missing file with a prefork scheduler' do
      skip "Scheduler::Prefork not available for #{RUBY_ENGINE}" if %w[jruby truffleruby].include?(RUBY_ENGINE)
      skip 'Scheduler::Prefork not available on Windows' if Opal::OS.windows?
      temporarily_with_prefork_scheduler { expect_missing_require_naming_the_file }
    end
  end

  describe 'directory mode' do
    shared_examples 'directory mode' do
      let(:options) { {compiler_options: {directory: true, esm: esm?}}}
      let(:ver) { Opal::VERSION_MAJOR_MINOR }

      it 'builds a correct directory structure' do
        Dir.mktmpdir("opal-test-") do |dir|
          builder.build('console')
          builder.compile_to_directory(dir+"/UniqueString/")

          files = Dir["#{dir}/**/*"].map { |i| i.split("/UniqueString/")[1] }.compact
          expected_files = %W[index.#{ext} opal opal/#{ver} opal/#{ver}/console.#{ext}
                              opal/#{ver}/console.map opal/#{ver}/native.#{ext} opal/#{ver}/native.map
                              opal/src opal/src/console.rb opal/src/native.rb]
          expected_files << 'index.html' if esm?
          expect(files.sort).to eq(expected_files.sort)
        end
      end

      it 'builds a single file if requested' do
        builder.build('console')
        file = builder.compile_to_directory(single_file: "opal/src/console.rb")
        expect(file).to eq(File.binread("#{__dir__}/../../stdlib/console.rb"))
      end
    end

    context 'with ESM enabled' do
      let(:esm?) { true }
      let(:ext) { "mjs" }
      include_examples 'directory mode'
    end

    context 'with ESM disabled' do
      let(:esm?) { false }
      let(:ext) { "js" }
      include_examples 'directory mode'
    end
  end
end
