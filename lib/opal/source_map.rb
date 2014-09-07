# require 'opal'
require 'source_map'

module Opal
  class SourceMap
    attr_reader :fragments
    attr_reader :file

    def initialize(fragments, file)
      @fragments = fragments
      @file = file
    end

    def map
      @map ||= begin
        source_file = file+'.rb'
        generated_line, generated_column = 1, 0

        mappings = @fragments.map do |fragment|
          mapping = nil
          source_line   = fragment.line
          source_column = fragment.column
          source_code   = fragment.code

          if source_line and source_column
            source_offset    = ::SourceMap::Offset.new(source_line, source_column)
            generated_offset = ::SourceMap::Offset.new(generated_line, generated_column)
            mapping          = ::SourceMap::Mapping.new(source_file, source_offset, generated_offset)
          end

          new_lines = source_code.count "\n"
          generated_line += new_lines

          if new_lines > 0
            generated_column = source_code.size - (source_code.rindex("\n") + 1)
          else
            generated_column += source_code.size
          end

          mapping
        end

        ::SourceMap::Map.new(mappings.compact)
      end
    end

    def as_json
      map.as_json
    end

    def to_s
      map.to_s
    end

    def magic_comment map_path
      "\n//# sourceMappingURL=file://#{map_path}"
    end
  end
end
