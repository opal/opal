require 'lib/spec_helper'
require 'opal/builder'

describe Opal::Builder::Watcher do
  context 'classic mode' do
    before :each do
      FileUtils.rm_rf('tmp/builder') if Dir.exist?('tmp/builder')
      FileUtils.mkdir_p('tmp/builder/oak')
      File.write('tmp/builder/test1.rb', <<~'RUBY'
      require 'opal'
      require_tree './oak'
      puts 'test1.rb compiled and executed'
      RUBY
      )
      File.write('tmp/builder/oak/leaf.rb', <<~'RUBY'
      puts 'got a leaf'
      RUBY
      )
      @builder = Opal::Builder.new(path_reader: Opal::PathReader.new(Opal.paths + [File.expand_path('tmp/builder/')]))
      @builder.build_str(File.read('tmp/builder/test1.rb'), 'test1.rb').to_s # compile everything once
    end

    it 'builds' do
      File.binwrite('tmp/builder/out.js', @builder.to_s)
      expect(`node tmp/builder/out.js`).to eq "got a leaf\ntest1.rb compiled and executed\n"
    end

    it 'detects a changed file and builds correctly' do
      File.write('tmp/builder/oak/leaf.rb', <<~'RUBY'
      puts 'got a leaf'
      puts 'got another leaf'
      RUBY
      )
      updates = @builder.updates
      expect(updates[:added].size).to eq 0
      expect(updates[:modified].size).to eq 2 # the asset containing the require_tree and the changed file
      expect(updates[:removed].size).to eq 0
      expect(updates[:error]).to be nil
      File.binwrite('tmp/builder/out.js', @builder.to_s)
      expect(`node tmp/builder/out.js`).to eq "got a leaf\ngot another leaf\ntest1.rb compiled and executed\n"
    end

    it 'detects a added file and builds correctly' do
      File.write('tmp/builder/oak/branch.rb', <<~'RUBY'
      require_relative 'leaf'
      puts 'got a branch'
      RUBY
      )
      updates = @builder.updates
      expect(updates[:added].size).to eq 1 # the file added to the required tree
      expect(updates[:modified].size).to eq 1 # the asset containing the require_tree
      expect(updates[:removed].size).to eq 0
      expect(updates[:error]).to be nil
      File.binwrite('tmp/builder/out.js', @builder.to_s)
      expect(`node tmp/builder/out.js`).to eq "got a leaf\ngot a branch\ntest1.rb compiled and executed\n"
    end

    it 'detects a deleted file' do
      FileUtils.rm_f('tmp/builder/oak/leaf.rb')
      updates = @builder.updates
      expect(updates[:added].size).to eq 0
      expect(updates[:modified].size).to eq 1 # the asset containing the require_tree
      expect(updates[:removed].size).to eq 1 # the removed file
      expect(updates[:error]).to be nil
      File.binwrite('tmp/builder/out.js', @builder.to_s)
      expect(`node tmp/builder/out.js`).to eq "test1.rb compiled and executed\n"
    end
  end

  context 'directory mode' do
    before :each do
      FileUtils.rm_rf('tmp/builder') if Dir.exist?('tmp/builder')
      FileUtils.mkdir_p('tmp/builder/test/oak')
      FileUtils.mkdir_p('tmp/builder/out')
      File.write('tmp/builder/test/test1.rb', <<~'RUBY'
      require 'opal'
      require_tree './oak'
      puts 'test1.rb compiled and executed'
      RUBY
      )
      File.write('tmp/builder/test/oak/leaf.rb', <<~'RUBY'
      puts 'got a leaf'
      RUBY
      )
      @builder = Opal::Builder.new(path_reader: Opal::PathReader.new(Opal.paths + [File.expand_path('tmp/builder/test')]),
                                   compiler_options: { esm: true, directory: true })
      @builder.build_str(File.read('tmp/builder/test/test1.rb'), 'test1.rb')
      @builder.compile_to_directory('tmp/builder/out') # compile everything once
    end

    it 'builds' do
      expect(`node tmp/builder/out/index.mjs`).to eq "got a leaf\ntest1.rb compiled and executed\n"
    end

    it 'detects a changed file' do
    end

    it 'detects a added file' do
    end

    it 'detects a deleted file' do
    end
  end
end
