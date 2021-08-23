# frozen_string_literal: true

class Opal::SourceMap::File
  include Opal::SourceMap::Map

  attr_reader :fragments
  attr_reader :file
  attr_reader :source

  def initialize(fragments, file, source, generated_code = nil)
    @fragments = fragments
    @file = file
    @source = source
    @names_map = Hash.new { |hash, name| hash[name] = hash.size }
    @generated_code = generated_code
    @absolute_mappings = nil
  end

  def generated_code
    @generated_code ||= @fragments.map(&:code).join
  end

  # Proposed Format
  # 1: {
  # 2: "version" : 3,
  # 3: "file": "out.js",
  # 4: "sourceRoot": "",
  # 5: "sources": ["foo.js", "bar.js"],
  # 6: "sourcesContent": [null, null],
  # 7: "names": ["src", "maps", "are", "fun"],
  # 8: "mappings": "A,AAAB;;ABCDE;"
  # 9: }
  #
  # Line 1: The entire file is a single JSON object
  # Line 2: File version (always the first entry in the object) and must be a
  #         positive integer.
  # Line 3: An optional name of the generated code that this source map is
  #         associated with.
  # Line 4: An optional source root, useful for relocating source files on a server
  #         or removing repeated values in the “sources” entry. This value is prepended to
  #         the individual entries in the “source” field.
  # Line 5: A list of original sources used by the “mappings” entry.
  # Line 6: An optional list of source content, useful when the “source” can’t be
  #         hosted. The contents are listed in the same order as the sources in line 5.
  #         “null” may be used if some original sources should be retrieved by name.
  # Line 7: A list of symbol names used by the “mappings” entry.
  # Line 8: A string with the encoded mapping data.
  def map(source_root: '')
    {
      version: 3,
      # file: "out.js", # This is optional
      sourceRoot: source_root,
      sources: [file],
      sourcesContent: [source.force_encoding('UTF-8')],
      names: names,
      mappings: Opal::SourceMap::VLQ.encode_mappings(relative_mappings),
      # x_com_opalrb_original_lines: source.count("\n"),
      # x_com_opalrb_generated_lines: generated_code.count("\n"),
    }
  end

  def names
    @names ||= begin
      absolute_mappings # let the processing happen
      @names_map.to_a.sort_by { |_, index| index }.map { |name, _| name }
    end
  end

  # The fields in each segment are:
  #
  # 1. The zero-based starting column of the line in the generated code that
  #    the segment represents. If this is the first field of the first segment, or
  #    the first segment following a new generated line (“;”), then this field
  #    holds the whole base 64 VLQ. Otherwise, this field contains a base 64 VLQ
  #    that is relative to the previous occurrence of this field. Note that this
  #    is different than the fields below because the previous value is reset
  #    after every generated line.
  #
  # 2. If present, an zero-based index into the “sources” list. This field is
  #    a base 64 VLQ relative to the previous occurrence of this field, unless
  #    this is the first occurrence of this field, in which case the whole value
  #    is represented.
  #
  # 3. If present, the zero-based starting line in the original source
  #    represented. This field is a base 64 VLQ relative to the previous
  #    occurrence of this field, unless this is the first occurrence of this
  #    field, in which case the whole value is represented. Always present if
  #    there is a source field.
  #
  # 4. If present, the zero-based starting column of the line in the source
  #    represented. This field is a base 64 VLQ relative to the previous
  #    occurrence of this field, unless this is the first occurrence of this
  #    field, in which case the whole value is represented. Always present if
  #    there is a source field.
  #
  # 5. If present, the zero-based index into the “names” list associated with
  #    this segment. This field is a base 64 VLQ relative to the previous
  #    occurrence of this field, unless this is the first occurrence of this
  #    field, in which case the whole value is represented.
  def segment_from_fragment(fragment, generated_column)
    source_index     = 0                          # always 0, we're dealing with a single file
    original_line    = fragment.line - 1          # fragments have 1-based lines
    original_line    = 0 if original_line < 0     # line 0 (-1) for fragments in source maps will crash
                                                  # browsers devtools and the webpack build process
    original_column  = fragment.column            # fragments have 0-based columns

    if fragment.source_map_name
      map_name_index = (@names_map[fragment.source_map_name.to_s] ||= @names_map.size)
      [
        generated_column,
        source_index,
        original_line,
        original_column,
        map_name_index,
      ]
    else
      [
        generated_column,
        source_index,
        original_line,
        original_column,
      ]
    end
  end

  def relative_mappings
    @relative_mappings ||= begin
      reference_segment = [0, 0, 0, 0, 0]
      reference_name_index = 0
      absolute_mappings.map do |absolute_mapping|
        # [generated_column, source_index, original_line, original_column, map_name_index]
        reference_segment[0] = 0 # reset the generated_column at each new line

        absolute_mapping.map do |absolute_segment|
          segment = []

          segment[0] = absolute_segment[0] -  reference_segment[0]
          segment[1] = absolute_segment[1] - (reference_segment[1] || 0)
          segment[2] = absolute_segment[2] - (reference_segment[2] || 0)
          segment[3] = absolute_segment[3] - (reference_segment[3] || 0)

          # Since [4] can be nil we need to keep track of it in the reference_segment even if it's nil in absolute_segment
          if absolute_segment[4]
            segment[4] = absolute_segment[4].to_int - (reference_segment[4] || reference_name_index).to_int
            reference_name_index = absolute_segment[4]
          end

          reference_segment = absolute_segment
          segment
        end
      end
    end
  end

  # The “mappings” data is broken down as follows:
  #
  # each group representing a line in the generated file is separated by a ”;”
  # each segment is separated by a “,”
  # each segment is made up of 1,4 or 5 variable length fields.
  def absolute_mappings
    @absolute_mappings ||= begin
      mappings = []

      fragments_by_line.each do |raw_segments|
        generated_column = 0
        segments = []
        raw_segments.each do |(generated_code, fragment)|
          if fragment.line && fragment.column
            segments << segment_from_fragment(fragment, generated_column)
          end
          generated_column += generated_code.size
        end
        mappings << segments
      end

      mappings
    end
  end

  private

  def fragments_by_line
    raw_mappings = [[]]
    fragments.flat_map do |fragment|
      fragment_code  = fragment.code
      fragment_lines = fragment_code.split("\n", -1) # a negative limit won't suppress trailing null values
      fragment_lines.each.with_index do |fragment_line, index|
        raw_segment = [fragment_line, fragment]
        if index.zero? && !fragment_line.size.zero?
          raw_mappings.last << raw_segment
        elsif index.zero? && fragment_line.size.zero?
          # noop
        elsif fragment_line.size.zero?
          raw_mappings << []
        else
          raw_mappings << [raw_segment]
        end
      end
    end
    raw_mappings
  end
end
