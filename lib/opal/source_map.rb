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
      @map ||= ::SourceMap.new.tap do |map|
        line, column = 1, 0

        @fragments.each do |fragment|
          if source_line = fragment.line
            map.add_mapping(
              :generated_line => line,
              :generated_col  => column,
              :source_line    => source_line,
              :source_col     => fragment.column,
              :source         => file
            )
          end

          new_lines = fragment.code.count "\n"
          line += new_lines

          if new_lines > 0
            column = fragment.code.size - (fragment.code.rindex("\n") + 1)
          else
            column += fragment.code.size
          end
        end
      end
    end

    def as_json
      map.as_json
    end

    def to_s
      map.to_s
    end

    def magic_comment map_path
      "\n//@ sourceMappingURL=file://#{map_path}"
    end
  end
end
