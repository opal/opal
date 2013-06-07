class SourceMap
  module Generator

    # An object (responding to <<) that will be written to whenever
    # {add_generated} is called.
    #
    # @example
    #
    #   File.open("/var/www/a.js.min"){ |f|
    #     map = SourceMap.new(:generated_output => f)
    #     map.add_generated('function(a,b,c){minified=1}\n', :source => 'a.js')
    #     map.save('/var/www/a.js.map')
    #   }
    #   File.read('/var/www/a.js.min') == 'function(a,b,c){minified=1}\n'
    #
    attr_accessor :generated_output

    # Add the mapping for generated code to this source map.
    #
    # The first parameter is the generated text that you're going to add to the output, if
    # it contains multiple lines of code then it will be added to the source map as
    # several mappings.
    #
    # If present, the second parameter represents the original source of the generated
    # fragment, and may contain:
    #
    # :source => String,           # The filename of the source fille that contains this fragment.
    # :source_line => Integer,     # The line in that file that contains this fragment
    # :source_col => Integer,      # The column in that line at which this fragment starts
    # :name => String              # The original name for this variable.
    # :exact_position => Bool      # Whether all lines in the generated fragment came from
    #                                the same position in the source.
    #
    # The :source key is required to set :source_line, :source_col or :name.
    #
    # If unset :source_line and :source_col default to 1,0 for the first line of the
    # generated fragment.
    #
    # Normally :source_line is incremented and :source_col reset at every line break in
    # the generated code (because we assume that you're copying a verbatim fragment from
    # the source into the generated code). If that is not the case, you can set
    # :exact_position => true, and then all lines in the generated output will be given
    # the same :source_line and :source_col.
    #
    # The :name property is used if the fragment you are adding contains only a name that
    # you have renamed in the source transformation.
    #
    # If you'd like to ensure that the source map stays in sync with the generated
    # source, consider calling {source_map.generated_output = StringIO.new} and then
    # accessing your generated javascript with {source_map.generated_output.string},
    # otherwise be careful to always write to both.
    #
    # NOTE: By long-standing convention, the first line of a file is numbered 1, not 0.
    #
    # NOTE: when generating a source map, you should either use this method always, or use
    # the {#add_mapping} method always.
    #
    def add_generated(text, opts={})
      if !opts[:source] && (opts[:name] || opts[:source_line] || opts[:source_col])
        raise "mapping must have :source to have :source_line, :source_col or :name"
      elsif opts[:source_line] && opts[:source_line] < 1
        raise "files start on line 1 (got :source_line => #{opts[:source_line]})"
      elsif !(remain = opts.keys - [:source, :source_line, :source_col, :name, :exact_position]).empty?
        raise "mapping had unexpected keys: #{remain.inspect}"
      end

      source_line = opts[:source_line] || 1
      source_col = opts[:source_col] || 0
      self.generated_line ||= 1
      self.generated_col ||= 0

      text.split(/(\n)/).each do |line|
        if line == "\n"
          self.generated_line += 1
          self.generated_col = 0
          unless opts[:exact_position]
            source_line += 1
            source_col = 0
          end
        elsif line != ""
          mapping = {
            :generated_line => generated_line,
            :generated_col => generated_col,
          }
          if opts[:source]
            mapping[:source] = opts[:source]
            mapping[:source_line] = source_line
            mapping[:source_col] = source_col
            mapping[:name] = opts[:name] if opts[:name]
          end

          mappings << mapping

          self.generated_col += line.size
          source_col += line.size unless opts[:exact_position]
        end
      end

      generated_output << text if generated_output
    end

    # Add a mapping to the list for this object.
    #
    # A mapping identifies a fragment of code that has been moved around during
    # transformation from the source file to the generated file. The fragment should
    # be contiguous and not contain any line breaks.
    #
    # Mappings are Hashes with a valid subset of the following 6 keys:
    #
    # :generated_line => Integer,  # The line in the generated file that contains this fragment.
    # :generated_col  => Integer,  # The column in the generated_line that this mapping starts on
    # :source => String,           # The filename of the source fille that contains this fragment.
    # :source_line => Integer,     # The line in that file that contains this fragment.
    # :source_col => Integer,      # The column in that line at which this fragment starts.
    # :name => String              # The original name for this variable (if applicable).
    #
    #
    # The only 3 valid subsets of keys are:
    #   [:generated_line, :generated_col] To indicate that this is a fragment in the
    #   output file that you don't have the source for.
    #
    #   [:generated_line, :generated_col, :source, :source_line, :source_col] To indicate
    #   that this is a fragment in the output file that you do have the source for.
    #
    #   [:generated_line, :generated_col, :source, :source_line, :source_col, :name] To
    #   indicate that this is a particular identifier at a particular location in the original.
    #
    # Any other combination of keys would produce an invalid source map.
    #
    # NOTE: By long-standing convention, the first line of a file is numbered 1, not 0.
    #
    # NOTE: when generating a source map, you should either use this method always,
    # or use the {#add_generated} method always.
    #
    def add_mapping(map)
      if !map[:generated_line] || !map[:generated_col]
        raise "mapping must have :generated_line and :generated_col"
      elsif map[:source] && !(map[:source_line] && map[:source_col])
        raise "mapping must have :source_line and :source_col if it has :source"
      elsif !map[:source] && (map[:source_line] || map[:source_col])
        raise "mapping may not have a :source_line or :source_col without a :source"
      elsif map[:name] && !map[:source]
        raise "mapping may not have a :name without a :source"
      elsif map[:source_line] && map[:source_line] < 1
        raise "files start on line 1 (got :source_line => #{map[:source_line]})"
      elsif map[:generated_line] < 1
        raise "files start on line 1 (got :generated_line => #{map[:generated_line]})"
      elsif !(remain = map.keys - [:generated_line, :generated_col, :source, :source_line, :source_col, :name]).empty?
        raise "mapping had unexpected keys: #{remain.inspect}"
      end

      mappings << map
    end

    # Convert the map into an object suitable for direct serialisation.
    def as_json
      serialized_mappings = serialize_mappings!

      {
        'version' => version,
        'file' => file,
        'sourceRoot' => source_root,
        'sources' => sources,
        'names' => names,
        'mappings' => serialized_mappings
      }
    end

    # Convert the map to a string.
    def to_s
      as_json.to_json
    end

    # Write this map to a file.
    def save(file)
      File.open(file, "w"){ |f| f << to_s }
    end

    protected

    attr_reader :source_ids, :name_ids
    attr_accessor :generated_line, :generated_col

    # Get the id for the given file. If we've not
    # seen this file before, add it to the list.
    def source_id(file)
      source_ids[file] ||= (
        sources << file
        sources.size - 1
      )
    end

    # Get the id for the given name. If we've not
    # seen this name before, add it to the list.
    def name_id(name)
      name_ids[name] ||= (
        names << name
        names.size - 1
      )
    end

    # Encode a vlq. As each field in the output should be relative to the
    # previous occurance of that field, we keep track of each one.
    def vlq(num, type)
      ret = num - @previous_vlq[type]
      @previous_vlq[type] = num
      VLQ.encode(ret)
    end

    # Serialize the list of mappings into the string of base64 variable length
    # quanities. As a side-effect, regenerate the sources and names arrays.
    def serialize_mappings!
      # clear all internals as we're about to re-generate them.
      @sources  = []
      @source_ids = {}
      @names    = []
      @name_ids = {}
      @previous_vlq = Hash.new{ 0 }

      return "" if mappings.empty?

      by_lines = mappings.group_by{ |x| x[:generated_line] }

      (1..by_lines.keys.max).map do |line|
        # reset the generated_col on each line as indicated by the VLQ spec.
        # (the other values continue to be relative)
        @previous_vlq[:generated_col] = 0

        fragments = (by_lines[line] || []).sort_by{ |x| x[:generated_col] }
        fragments.map do |map|
          serialize_mapping(map)
        end.join(",")
      end.join(";")
    end

    def serialize_mapping(map)
      item = vlq(map[:generated_col], :generated_col)
      if map[:source]
        item << vlq(source_id(map[:source]), :source)
        item << vlq(map[:source_line] - 1, :source_line)
        item << vlq(map[:source_col], :source_col)
        item << vlq(name_id(map[:name]), :name) if map[:name]
      end
      item
    end
  end
end
