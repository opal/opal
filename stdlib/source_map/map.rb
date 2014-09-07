require 'json'

require 'source_map/offset'
require 'source_map/mapping'
require 'source_map/vlq'

module SourceMap
  class Map
    include Enumerable

    def self.from_json(json)
      from_hash JSON.parse(json)
    end

    def self.from_hash(hash)
      str     = hash['mappings']
      sources = hash['sources']
      names   = hash['names']

      mappings = decode_vlq_mappings(str, sources, names)
      new(mappings, hash['file'])
    end

    # Internal: Decode VLQ mappings and match up sources and symbol names.
    #
    # str     - VLQ string from 'mappings' attribute
    # sources - Array of Strings from 'sources' attribute
    # names   - Array of Strings from 'names' attribute
    #
    # Returns an Array of Mappings.
    def self.decode_vlq_mappings(str, sources = [], names = [])
      mappings = []

      source_id       = 0
      original_line   = 1
      original_column = 0
      name_id         = 0

      VLQ.decode_mappings(str).each_with_index do |group, index|
        generated_column = 0
        generated_line   = index + 1

        group.each do |segment|
          generated_column += segment[0]
          generated = Offset.new(generated_line, generated_column)

          if segment.size >= 4
            source_id        += segment[1]
            original_line    += segment[2]
            original_column  += segment[3]

            source   = sources[source_id]
            original = Offset.new(original_line, original_column)
          else
            # TODO: Research this case
            next
          end

          if segment[4]
            name_id += segment[4]
            name     = names[name_id]
          end

          mappings << Mapping.new(source, generated, original, name)
        end
      end

      mappings
    end

    def initialize(mappings = [], filename = nil)
      @mappings, @filename = mappings, filename
    end

    attr_reader :filename

    def size
      @mappings.size
    end

    def [](i)
      @mappings[i]
    end

    def each(&block)
      @mappings.each(&block)
    end

    def to_s
      @string ||= build_vlq_string
    end

    def sources
      @sources ||= @mappings.map(&:source).uniq.compact
    end

    def names
      @names ||= @mappings.map(&:name).uniq.compact
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      other.is_a?(self.class) &&
        self.mappings == other.mappings &&
        self.filename == other.filename
    end

    def +(other)
      mappings = @mappings.dup
      offset   = @mappings.any? ? @mappings.last.generated.line+1 : 0
      other.each do |m|
        mappings << Mapping.new(
          m.source, m.generated + offset,
          m.original, m.name
        )
      end
      self.class.new(mappings, other.filename)
    end

    def |(other)
      return other.dup if self.mappings.empty?

      mappings = []

      other.each do |m|
        om = bsearch(m.original)
        next unless om

        mappings << Mapping.new(
          om.source, m.generated,
          om.original, om.name
        )
      end

      self.class.new(mappings, other.filename)
    end

    def bsearch(offset, from = 0, to = size - 1)
      mid = (from + to) / 2

      # We haven't found a match
      if from > to
        return from < 1 ? nil : self[from-1]
      end

      # We found an exact match
      if offset == self[mid].generated
        self[mid]

      # We need to filter more
      elsif offset < self[mid].generated
        bsearch(offset, from, mid - 1)
      elsif offset > self[mid].generated
        bsearch(offset, mid + 1, to)
      end
    end

    def as_json
      {
        "version"   => 3,
        "file"      => filename,
        "mappings"  => to_s,
        "sources"   => sources,
        "names"     => names
      }
    end

    # Public: Get a pretty inspect output for debugging purposes.
    #
    # Returns a String.
    def inspect
      str = "#<#{self.class}"
      str << " filename=#{filename.inspect}" if filename
      str << " mappings=#{mappings.map(&:to_s).inspect}" if mappings.any?
      str << ">"
      str
    end

    protected
      attr_reader :mappings

      def build_vlq_string
        source_id        = 0
        source_line      = 1
        source_column    = 0
        name_id          = 0

        by_lines = @mappings.group_by { |m| m.generated.line }

        sources_index = Hash[sources.each_with_index.to_a]
        names_index   = Hash[names.each_with_index.to_a]

        ary = (1..by_lines.keys.max).map do |line|
          generated_column = 0

          (by_lines[line] || []).map do |mapping|
            group = []
            group << mapping.generated.column - generated_column
            group << sources_index[mapping.source] - source_id
            group << mapping.original.line - source_line
            group << mapping.original.column - source_column
            group << names_index[mapping.name] - name_id if mapping.name

            generated_column = mapping.generated.column
            source_id        = sources_index[mapping.source]
            source_line      = mapping.original.line
            source_column    = mapping.original.column
            name_id          = names_index[mapping.name] if mapping.name

            group
          end
        end

        VLQ.encode_mappings(ary)
      end
  end
end
