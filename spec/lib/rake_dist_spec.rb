require 'lib/spec_helper'
require 'fileutils'
require 'open3'
require 'opal/os'
require 'tmpdir'

RSpec.describe "rake dist" do
  before :all do
    @build_dir = Dir.mktmpdir('opal-dist-spec-')
    built = system(
      {
        'DIR' => @build_dir,
        'FILES' => 'opal,opal/mini,opal/full,opal-replutils',
        'FORMATS' => 'js',
      },
      'rake', 'dist',
      out: Opal::OS.dev_null
    )

    raise 'rake dist failed for spec/lib/rake_dist_spec.rb' unless built
  end

  after :all do
    FileUtils.remove_entry(@build_dir) if @build_dir
  end

  def run_with_node(code, precode:, requires:)
    requires = requires.map do |i|
      "require(#{File.join(@build_dir, i).inspect});"
    end.join

    code = "#{requires};#{precode};console.log(#{code});"

    stdout, _, status = Open3.capture3('node', '-e', code)

    expect(status.exitstatus).to eq(0)

    stdout.chomp
  end

  let(:output) { run_with_node(code, precode: precode, requires: requires) }
  let(:requires) { ['opal'] }
  let(:precode) { '' }
  let(:code) { 'typeof Opal' }

  it 'should provide a working Opal environment' do
    expect(output).to eq('object')
  end

  context do
    let(:requires) { ['opal/mini'] }

    it 'should provide a working Opal mini environment' do
      expect(output).to eq('object')
    end
  end

  context do
    let(:requires) { ['opal', 'opal/full'] }
    let(:precode) { 'Opal.require("corelib/pattern_matching")' }
    let(:code) { 'typeof Opal.PatternMatching' }

    it 'should provide a working Opal full environment' do
      expect(output).to eq('function')
    end
  end

  context do
    let(:requires) { %w[opal opal-replutils] }
    let(:code) { 'typeof Opal.REPLUtils' }

    it 'should not require requirable files by default' do
      expect(output).to eq('undefined')
    end
  end

  context do
    let(:requires) { %w[opal opal-replutils] }
    let(:precode) { 'Opal.require("opal-replutils")' }
    let(:code) { 'typeof Opal.REPLUtils' }

    it 'should allow user to require requirable files to provide missing functionality' do
      expect(output).to eq('function')
    end
  end
end
