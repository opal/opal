# frozen_string_literal: true

class Opal::SourceMap::Index
  include Opal::SourceMap::Map

  attr_reader :source_maps

  # @param source_maps [Opal::SourceMap::File]
  # @param join: the string used to join the sources, empty by default, Opal::Builder uses "\n"
  def initialize(source_maps, join: nil)
    @source_maps = source_maps
    @join = join
  end

  # To support concatenating generated code and other common post processing, an
  # alternate representation of a map is supported:
  #
  #  1: {
  #  2: version : 3,
  #  3: file: “app.js”,
  #  4: sections: [
  #  5:  { offset: {line:0, column:0}, url: “url_for_part1.map” }
  #  6:  { offset: {line:100, column:10}, map:
  #  7:    {
  #  8:      version : 3,
  #  9:      file: “section.js”,
  # 10:      sources: ["foo.js", "bar.js"],
  # 11:      names: ["src", "maps", "are", "fun"],
  # 12:      mappings: "AAAA,E;;ABCDE;"
  # 13:    }
  # 14:  }
  # 15: ],
  # 16: }
  #
  # The index map follow the form of the standard map
  #
  # Line 1: The entire file is an JSON object.
  # Line 2: The version field. See the description of the standard map.
  # Line 3: The name field. See the description of the standard map.
  # Line 4: The sections field.
  #
  # The “sections” field is an array of JSON objects that itself has two fields
  # “offset” and a source map reference. “offset” is an object with two fields,
  # “line” and “column”, that represent the offset into generated code that the
  # referenced source map represents.
  #
  # The other field must be either “url” or “map”. A “url” entry must be a URL
  # where a source map can be found for this section and the url is resolved in the
  # same way as the “sources” fields in the standard map. A “map” entry must be an
  # embedded complete source map object. An embedded map does not inherit any
  # values from the containing index map.
  #
  # The sections must be sorted by starting position and the represented sections
  # may not overlap.
  #
  def map
    offset_line = 0
    offset_column = 0
    {
      version: 3,
      # file: "app.js",
      sections: @source_maps.map do |source_map|
        map = {
          offset: {
            line: offset_line,
            column: offset_column,
          },
          map: source_map.to_h,
        }

        generated_code  = source_map.generated_code
        generated_code += @join if @join
        new_lines_count = generated_code.count("\n")
        last_line       = generated_code[generated_code.rindex("\n") + 1..-1]

        offset_line    += new_lines_count
        offset_column  += last_line.size

        map
      end
    }
  end
end
