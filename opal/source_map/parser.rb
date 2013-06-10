class SourceMap

  class ParserError < RuntimeError; end

  # Load a SourceMap from a Hash such as might be returned by
  # {SourceMap#as_json}.
  #
  def self.from_json(json)
    raise ParserError, "Cannot parse version: #{json['version']} of SourceMap" unless json['version'] == 3

    map = new(:file => json['file'],
              :source_root => json['sourceRoot'],
              :sources => json['sources'],
              :names => json['names'])

    map.parse_mappings(json['mappings'] || '')
    map
  end

  # Load a SourceMap from a String.
  def self.from_s(str)
    from_json JSON.parse(str)
  end

  # Load a SourceMap from a file.
  def self.load(filename)
    from_s File.read(filename)
  end

  module Parser
    # Parse the mapping string from a SourceMap.
    #
    # The mappings string contains one comma-separated list of segments per line
    # in the output file, these lists are joined by semi-colons.
    #
    def parse_mappings(string)
      @previous = Hash.new{ 0 }

      string.split(";").each_with_index do |line, line_idx|
        # The generated_col resets to 0 at the start of every line, though
        # all the other differences are maintained.
        @previous[:generated_col] = 0
        line.split(",").each do |segment|
          mappings << parse_mapping(segment, line_idx + 1)
        end
      end

      self.mappings = self.mappings.sort_by{ |x| [x[:generated_line], x[:generated_col]] }
    end

    # All the numbers in SourceMaps are stored as differences from each other,
    # so we need to remove the difference every time we read a number.
    def undiff(int, type)
      @previous[type] += int
    end

    # Parse an individual mapping.
    #
    # This is a list of variable-length-quanitity, with 1, 4 or 5 items. See the spec
    # https://docs.google.com/document/d/1U1RGAehQwRypUTovF1KRlpiOFze0b-_2gc6fAH0KY0k/edit
    # for more details.
    def parse_mapping(segment, line_num)
      item = VLQ.decode_array(segment)

      unless [1, 4, 5].include?(item.size)
        raise ParserError, "In map for #{file}:#{line_num}: unparseable item: #{segment}"
      end

      map = {
        :generated_line => line_num,
        :generated_col => undiff(item[0], :generated_col),
      }

      if item.size >= 4
        map[:source] = sources[undiff(item[1], :source_id)]
        map[:source_line] = undiff(item[2], :source_line) + 1 # line numbers are stored starting from 0
        map[:source_col] = undiff(item[3], :source_col)
        map[:name] = names[undiff(item[4], :name_id)] if item[4]
      end

      if map[:generated_col] < 0
        raise ParserError, "In map for #{file}:#{line_num}: unexpected generated_col: #{map[:generated_col]}"

      elsif map.key?(:source) && (map[:source].nil? || @previous[:source_id] < 0)
        raise ParserError, "In map for #{file}:#{line_num}: unknown source id: #{@previous[:source_id]}"

      elsif map.key?(:source_line) && map[:source_line] < 1
        raise ParserError, "In map for #{file}:#{line_num}: unexpected source_line: #{map[:source_line]}"

      elsif map.key?(:source_col) && map[:source_col] < 0
        raise ParserError, "In map for #{file}:#{line_num}: unexpected source_col: #{map[:source_col]}"

      elsif map.key?(:name) && (map[:name].nil? || @previous[:name_id] < 0)
        raise ParserError, "In map for #{file}:#{line_num}: unknown name id: #{@previous[:name_id]}"

      else
        map

      end
    end
  end
end
