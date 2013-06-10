require 'opal'
require 'source_map'

module Opal
  class SourceMap
    LINE_REGEXP = %r{/\*:(\d+)\*/}.freeze
    FILE_REGEXP = %r{/\*-file:(.+?)-\*/}.freeze

    attr_reader :generated, :file

    def initialize generated, file
      @generated = generated
      @file = file
    end

    def map
      @map ||= ::SourceMap.new.tap do |map|
        source_file = file
        generated.lines.each_with_index do |line, index|
          generated_line = index+1
          if line =~ FILE_REGEXP
            source_file = "file://#{$1}"
            map.add_mapping(
              :generated_line => generated_line,
              :generated_col  => 0,
              :source_line    => 1,
              :source_col     => 0,
              :source         => source_file
            )
          end

          pos = 0
          while (pos = line.index(LINE_REGEXP, pos))
            pos          += $~.size
            source_line   = $1.to_i + 1
            source_col    = 0 # until column info will be available
            generated_col = pos
            map.add_mapping(
              :generated_line => generated_line,
              :generated_col  => generated_col,
              :source_line    => source_line,
              :source_col     => source_col,
              :source         => source_file
            )
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
