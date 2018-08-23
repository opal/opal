module SourceMapHelper
  extend self

  # Just for debugging purposes
  def inspect_source(source)
    puts source_with_lines(source)
  end

  # Just for debugging purposes
  def source_with_lines(source)
    source.split("\n", -1).map.with_index { |line, index| "#{(index).to_s.rjust(3)} | #{line}" }.join("\n")
  end

  def fragment(line: nil, column: nil, source_map_name: nil, code: '', sexp_type: nil)
    double('Fragment', line: line, column: column, source_map_name: source_map_name, code: code, sexp_type: sexp_type)
  end

  SourcePosition = Struct.new(:line, :column, :file) do
    def inspect
      "#<SourcePosition line:#{line} column:#{column} file:#{file.inspect}>"
    end
    alias_method :to_s, :inspect

    def in_source(source)
      source.split("\n", -1)[line].to_s[column..-1]
    end

    def self.absolutize_mappings(relative_mappings)
      reference_segment = [0, 0, 0, 0, 0]
      relative_mappings.map do |relative_mapping|
        # Reference: [generated_column, source_index, original_line, original_column, map_name_index]
        reference_segment[0] = 0 # reset the generated_column at each new line

        relative_mapping.map do |relative_segment|
          segment = []

          segment[0] = relative_segment[0].to_int +  reference_segment[0].to_int
          segment[1] = relative_segment[1].to_int + (reference_segment[1] || 0).to_int if relative_segment[1]
          segment[2] = relative_segment[2].to_int + (reference_segment[2] || 0).to_int if relative_segment[2]
          segment[3] = relative_segment[3].to_int + (reference_segment[3] || 0).to_int if relative_segment[3]
          segment[4] = relative_segment[4].to_int + (reference_segment[4] || 0).to_int if relative_segment[4]

          reference_segment = segment
          segment
        end
      end
    end

    def find_section_in_map_index(index_map)
      sections = index_map.to_h[:sections]
      section, section_index = sections.each.with_index.find do |map, index|
        next_map = sections[index + 1] or next true # if there's no next map the current one is good

        (
          line > map[:offset][:line] || (line == map[:offset][:line] && column >= map[:offset][:column])
        ) && (
          line < next_map[:offset][:line] || (line == next_map[:offset][:line] && column < map[:offset][:column])
        )
      end

      next_section = sections[section_index + 1]

      section or raise "no map found for #{inspect} among available sections: #{sections.map { |s| s[:offset] }}"
    end

    def mapped_with(map)
      case map
      when Opal::SourceMap::Index
        offset_section = find_section_in_map_index(map)

        offset = offset_section[:offset] || raise(offset_section.inspect)

        offset_line = line - offset[:line]
        offset_column = line.zero? ? (column - offset[:column]) : column
        offset_position = self.class.new(offset_line, offset_column, offset_section[:map][:sources].first)

        offset_position.mapped_with_file_map(offset_section[:map])

      when Opal::SourceMap::File
        mapped_with_file_map(map.to_h)

      else raise "unknown map type: #{map.inspect}"
      end
    end

    def mapped_with_file_map(map_to_h)
      relative_mappings = Opal::SourceMap::VLQ.decode_mappings(map_to_h[:mappings])
      absolute_mappings = SourcePosition.absolutize_mappings(relative_mappings)
      mappings_line = absolute_mappings[line] or raise(
        "can't find a mapping for #{inspect} in the available #{absolute_mappings.size} absolute mappings: #{absolute_mappings.inspect}"
      )

      # keep all segments with a column from the required position on
      code_before_segment_strategy = -> segments {
        segments.select do |segment|
          segment[0] >= column
        end.sort_by do |segment|
          segment[0] - column # sort by the distance from the required position
        end.first
      }

      code_after_segment_strategy = -> segments {
        segments.select do |segment|
          column >= segment[0]
        end.sort_by do |segment|
          column - segment[0] # sort by the distance from the required position
        end.first
      }

      absolute_segments = absolute_mappings[line] or raise
      matched_segment = code_before_segment_strategy[absolute_segments] || code_after_segment_strategy[absolute_segments]

      raise "can't find a matching segment for #{inspect} in #{absolute_mappings[line]}" unless matched_segment

      source_index    = matched_segment[1]
      original_source = map_to_h[:sources][source_index]
      original_line   = matched_segment[2]
      original_column = matched_segment[3]

      self.class.new(original_line, original_column, original_source)
    end

    def original_source(map)
      map_to_h = map.to_h
      matching_source = -> map_data { map_data[:sourcesContent].first if map_data[:sources] == [file] }
      (map_to_h[:sections] || [{offset: {}, map: map_to_h}]).map { |section| matching_source[section[:map]] }.compact.first or
      raise "can't find a source for #{file.inspect} in #{map_to_h.to_json}"
    end

    def self.find_code(code, source:)
      line_contents, line = source.split("\n", -1).to_enum.with_index.find do |contents, index|
        contents.include? code
      end
      return nil if line_contents.nil?
      column = line_contents.index(code)
      new(line, column)
    end
  end

  RSpec::Matchers.define :be_at_line_and_column do |line, column, source:|
    expected_position = SourcePosition.new(line, column)

    match do |code|
      actual_position = SourcePosition.find_code(code, source: source)
      actual_position == expected_position
    end

    failure_message do |code|
      actual_position = SourcePosition.find_code(code, source: source)
      actual_code = expected_position.in_source(source)
      "expected #{code.inspect} to be at #{expected_position}, " +
      "instead #{actual_code.inspect} was found at the expected position, while code was found at #{actual_position}"
    end
  end

  RSpec::Matchers.define :be_mapped_to_line_and_column do |line, column, source:, map:, file: nil|
    expected_position = SourcePosition.new(line, column, file)

    match do |code|
      actual_position = SourcePosition.find_code(code, source: source).mapped_with(map)
      actual_position == expected_position
    end

    failure_message do |code|
      code_position = SourcePosition.find_code(code, source: source)
      actual_position = code_position.mapped_with(map)

      expected_source = expected_position.original_source(map)
      expected_code   = expected_position.in_source(expected_source)

      actual_source   = actual_position.original_source(map)
      actual_code     = actual_position.in_source(actual_source)

      if Opal::SourceMap::Index === map
        actual_section   = actual_position.find_section_in_map_index(map)
        expected_section = expected_position.find_section_in_map_index(map)
        map.to_h[:sections].each { |s| p s[:offset] }
        actual_offset   = " (offset: #{actual_section[:offset]})"
        expected_offset = " (offset: #{expected_section[:offset]})"
      end

      "expected #{code.inspect} at #{code_position.inspect} to be mapped to #{expected_position.inspect}" +
      "\n\nEXPECTED #{expected_code.inspect} at #{expected_position}#{expected_offset}:\n"+
      source_with_lines(expected_source) +
      "\n\nACTUAL #{actual_code.inspect} at #{actual_position}#{actual_offset}:\n"+
      source_with_lines(actual_source) +
      "\n"
    end
  end
end
