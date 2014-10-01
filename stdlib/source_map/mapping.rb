require 'source_map/offset'

module SourceMap
  class Mapping < Struct.new(:source, :generated, :original, :name)
    # Public: Get a simple string representation of the mapping.
    #
    # Returns a String.
    def to_s
      str = "#{generated.line}:#{generated.column}"
      str << "->#{source}@#{original.line}:#{original.column}"
      str << "##{name}" if name
      str
    end

    # Public: Get a pretty inspect output for debugging purposes.
    #
    # Returns a String.
    def inspect
      str = "#<#{self.class} source=#{source.inspect}"
      str << " generated=#{generated}, original=#{original}"
      str << " name=#{name.inspect}" if name
      str << ">"
      str
    end
  end
end
