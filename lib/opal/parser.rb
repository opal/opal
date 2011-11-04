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

      {
        :code     => code,
        :methods  => @id_tbl,
        :ivars    => @ivar_tbl,
        :next     => @next_id
      }
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
    # Reset the parser for a new file.

    def reset file = nil
      @file     = file

      @indent   = ''
      @unique   = 0
      @symbols  = {}
      @sym_id   = 0
    end

    ##
    # All method ids. method_id => id

    attr_reader :id_tbl

    ##
    # All ivars. ivar_name => id

    attr_reader :ivar_tbl

  end
end
