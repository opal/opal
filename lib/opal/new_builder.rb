require 'opal/compiler'

module Opal
  class NewBuilder
    def initialize(path_finder, compiler = Compiler.new)
      @path_finder = path_finder
      @compiler    = compiler
    end

    def build(path)
      source = path_finder.read(path)
      compiled_source = compiler.compile(source, :file => path)
      requires = compiler.requires
      compiled_requires = requires.map { |r| compiler.compile(path_finder.read(r), :file => r, :requirable => true) }.join
      compiled_requires + compiled_source
    end


    private

    attr_reader :compiler, :path_finder
  end
end
