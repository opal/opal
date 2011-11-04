require 'ruby_parser'

require 'opal/parser/processor'
require 'opal/parser/scope'

module Opal
  class Parser

    def initialize
      @id_tbl     = {}
      @ivar_tbl   = {}

      @global_ids   = {}
      @global_ivars = {}
      @next_id      = "a"
    end

    def parse(source, options = {})
      @options = options
      @file    = "__OPAL_LIB_FILE_STRING"

      begin
        parser = RubyParser.new
      rescue => e
        raise e.message + " (on line #{parser.lexer.lineno})\n#{parser.lexer.src.peek 100}"
      end

      reset
      code = top parser.parse(source, @file), options

      result = {
        :code     => code,
        :methods  => @id_tbl,
        :ivars    => @ivar_tbl,
        :next     => @next_id
      }

      @global_ids.merge! @id_tbl
      @global_ivars.merge! @ivar_tbl

      result
    end

    ##
    # Builds the given parse data hash into a format ready to pass to
    # opal in a browser/command line. This returns a string of the
    # form:
    #
    #     opal.parse_data({
    #       "methods": { ... },
    #       "ivars": { ... },
    #       "next": ..
    #     });

    def build_parse_data data
      methods = data[:methods].to_a.map do |m|
        "#{m[0].inspect}: #{m[1].inspect}"
      end

      ivars = data[:ivars].to_a.map do |i|
        "#{i[0].inspect}: #{i[1].inspect}"
      end

      next_id = data[:next].inspect

      <<-CODE
        opal.parse_data({
          "methods": { #{methods.join(', ')} },
          "ivars": { #{ivars.join(', ')} },
          "next": #{next_id}
        });
      CODE
    end

    ##
    # Sets the main parser data. This is usually just loaded from
    # build/data.yml in the context. Parse data contains the method
    # ids and ivar ids to be used, as well as the next_id. If parsing
    # the core library from scratch then this will not be set (as we
    # want to build completely from the start again.
    #
    # Also, +Builder+ may save this table when caching built files
    # so that it can keep track of all methods ids used in the app.

    def parse_data= data
      @global_ids   = data["methods"]
      @global_ivars = data["ivars"]
      @next_id      = data["next"]
    end

    ##
    # Makes a new ivar intern for the given var name. This will
    # typically come from a +Context+ instance which uses a new
    # ivar name in the runtime. This will register the new intern
    # name and return the id.

    def make_ivar_intern name
      id = ivar_to_id name
      reset # must reset so that ivar isnt copied over to next parse

      id
    end

    def make_intern name
      id = name_to_id name
      reset

      id
    end

    ##
    # Reset the parser for a new file.

    def reset file = nil
      @file     = file

      @indent   = ''
      @unique   = 0
      @symbols  = {}
      @sym_id   = 0

      @global_ids.merge! @id_tbl
      @global_ivars.merge! @ivar_tbl

      @id_tbl   = {}
      @ivar_tbl = {}
    end

    ##
    # All method ids. method_id => id

    attr_reader :id_tbl

    ##
    # All ivars. ivar_name => id

    attr_reader :ivar_tbl

  end
end
