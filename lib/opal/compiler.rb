require 'set'
require 'opal/parser'
require 'opal/fragment'
require 'opal/nodes'

module Opal
  # Compile a string of ruby code into javascript.
  #
  # @example
  #
  #     Opal.compile "ruby_code"
  #     # => "string of javascript code"
  #
  # @see Opal::Compiler.new for compiler options
  #
  # @param source [String] ruby source
  # @param options [Hash] compiler options
  # @return [String] javascript code
  #
  def self.compile(source, options = {})
    Compiler.new(source, options).compile
  end

  # {Opal::Compiler} is the main class used to compile ruby to javascript code.
  # This class uses {Opal::Parser} to gather the sexp syntax tree for the ruby
  # code, and then uses {Opal::Node} to step through the sexp to generate valid
  # javascript.
  #
  # @example
  #   Opal::Compiler.new("ruby code").compile
  #   # => "javascript code"
  #
  # @example Accessing result
  #   compiler = Opal::Compiler.new("ruby_code")
  #   compiler.compile
  #   compiler.result # => "javascript code"
  #
  # @example Source Maps
  #   compiler = Opal::Compiler.new("")
  #   compiler.compile
  #   compiler.source_map # => #<SourceMap:>
  #
  class Compiler
    # Generated code gets indented with two spaces on each scope
    INDENT = '  '

    # All compare method nodes - used to optimize performance of
    # math comparisons
    COMPARE = %w[< > <= >=]

    # defines a compiler option, also creating method of form 'name?'
    def self.compiler_option(name, default_value, options = {})
      mid          = options[:as]
      valid_values = options[:valid_values]
      define_method(mid || name) do
        value = @options.fetch(name) { default_value }
        raise ArgumentError if valid_values and not(valid_values.include?(value))
        value
      end
    end

    # @!method file
    #
    # The filename to use for compiling this code. Used for __FILE__ directives
    # as well as finding relative require()
    #
    # @return [String]
    compiler_option :file, '(file)'

    # @!method method_missing?
    #
    # adds method stubs for all used methods in file
    #
    # @return [Boolean]
    compiler_option :method_missing, true, :as => :method_missing?

    # @!method arity_check?
    #
    # adds an arity check to every method definition
    #
    # @return [Boolean]
    compiler_option :arity_check, false, :as => :arity_check?

    # @!method irb?
    #
    # compile top level local vars with support for irb style vars
    compiler_option :irb, false, :as => :irb?

    # @!method dynamic_require_severity
    #
    # how to handle dynamic requires (:error, :warning, :ignore)
    compiler_option :dynamic_require_severity, :error, :valid_values => [:error, :warning, :ignore]

    # @!method requirable?
    #
    # Prepare the code for future requires
    compiler_option :requirable, false, :as => :requirable?

    # @!method inline_operators?
    #
    # are operators compiled inline
    compiler_option :inline_operators, false, :as => :inline_operators?

    # @return [String] The compiled ruby code
    attr_reader :result

    # @return [Array] all [Opal::Fragment] used to produce result
    attr_reader :fragments

    # Current scope
    attr_accessor :scope

    # Current case_stmt
    attr_reader :case_stmt

    # Any content in __END__ special construct
    attr_reader :eof_content

    def initialize(source, options = {})
      @source = source
      @indent = ''
      @unique = 0
      @options = options
    end

    # Compile some ruby code to a string.
    #
    # @return [String] javascript code
    def compile
      @parser = Parser.new

      @sexp = s(:top, @parser.parse(@source, self.file) || s(:nil))
      @eof_content = @parser.lexer.eof_content

      @fragments = process(@sexp).flatten

      @result = @fragments.map(&:code).join('')
    end

    # Returns a source map that can be used in the browser to map back to
    # original ruby code.
    #
    # @param source_file [String] optional source_file to reference ruby source
    # @return [Opal::SourceMap]
    def source_map(source_file = nil)
      Opal::SourceMap.new(@fragments, source_file || self.file)
    end

    # Any helpers required by this file. Used by {Opal::Nodes::Top} to reference
    # runtime helpers that are needed. These are used to minify resulting
    # javascript by keeping a reference to helpers used.
    #
    # @return [Set<Symbol>]
    def helpers
      @helpers ||= Set.new([:breaker, :slice])
    end

    # Operator helpers
    def operator_helpers
      @operator_helpers ||= Set.new
    end

    # Method calls made in this file
    def method_calls
      @method_calls ||= Set.new
    end

    # This is called when a parsing/processing error occurs. This
    # method simply appends the filename and curent line number onto
    # the message and raises it.
    def error(msg, line = nil)
      raise SyntaxError, "#{msg} :#{file}:#{line}"
    end

    # This is called when a parsing/processing warning occurs. This
    # method simply appends the filename and curent line number onto
    # the message and issues a warning.
    def warning(msg, line = nil)
      warn "WARNING: #{msg} -- #{file}:#{line}"
    end

    # Instances of `Scope` can use this to determine the current
    # scope indent. The indent is used to keep generated code easily
    # readable.
    def parser_indent
      @indent
    end

    # Create a new sexp using the given parts. Even though this just
    # returns an array, it must be used incase the internal structure
    # of sexps does change.
    def s(*parts)
      Sexp.new(parts)
    end

    def fragment(str, sexp = nil)
      Fragment.new(str, sexp)
    end

    # Used to generate a unique id name per file. These are used
    # mainly to name method bodies for methods that use blocks.
    def unique_temp
      "TMP_#{@unique += 1}"
    end

    # Use the given helper
    def helper(name)
      self.helpers << name
    end

    # To keep code blocks nicely indented, this will yield a block after
    # adding an extra layer of indent, and then returning the resulting
    # code after reverting the indent.
    def indent(&block)
      indent = @indent
      @indent += INDENT
      @space = "\n#@indent"
      res = yield
      @indent = indent
      @space = "\n#@indent"
      res
    end

    # Temporary varibales will be needed from time to time in the
    # generated code, and this method will assign (or reuse) on
    # while the block is yielding, and queue it back up once it is
    # finished. Variables are queued once finished with to save the
    # numbers of variables needed at runtime.
    def with_temp(&block)
      tmp = @scope.new_temp
      res = yield tmp
      @scope.queue_temp tmp
      res
    end

    # Used when we enter a while statement. This pushes onto the current
    # scope's while stack so we know how to handle break, next etc.
    def in_while
      return unless block_given?
      @while_loop = @scope.push_while
      result = yield
      @scope.pop_while

      result
    end

    def in_case
      return unless block_given?
      old = @case_stmt
      @case_stmt = {}
      yield
      @case_stmt = old
    end

    # Returns true if the parser is curently handling a while sexp,
    # false otherwise.
    def in_while?
      @scope.in_while?
    end

    # Process the given sexp by creating a node instance, based on its type,
    # and compiling it to fragments.
    def process(sexp, level = :expr)
      return fragment('') if sexp == nil

      if handler = handlers[sexp.type]
        return handler.new(sexp, level, self).compile_to_fragments
      else
        raise "Unsupported sexp: #{sexp.type}"
      end
    end

    def handlers
      @handlers ||= Opal::Nodes::Base.handlers
    end

    # An array of requires used in this file
    def requires
      @requires ||= []
    end

    # An array of trees required in this file
    # (typically by calling #require_tree)
    def required_trees
      @required_trees ||= []
    end

    # The last sexps in method bodies, for example, need to be returned
    # in the compiled javascript. Due to syntax differences between
    # javascript any ruby, some sexps need to be handled specially. For
    # example, `if` statemented cannot be returned in javascript, so
    # instead the "truthy" and "falsy" parts of the if statement both
    # need to be returned instead.
    #
    # Sexps that need to be returned are passed to this method, and the
    # alterned/new sexps are returned and should be used instead. Most
    # sexps can just be added into a `s(:return) sexp`, so that is the
    # default action if no special case is required.
    def returns(sexp)
      return returns s(:nil) unless sexp

      case sexp.type
      when :break, :next, :redo
        sexp
      when :yield
        sexp[0] = :returnable_yield
        sexp
      when :scope
        sexp[1] = returns sexp[1]
        sexp
      when :block
        if sexp.length > 1
          sexp[-1] = returns sexp[-1]
        else
          sexp << returns(s(:nil))
        end
        sexp
      when :when
        sexp[2] = returns(sexp[2])
        sexp
      when :rescue
        sexp[1] = returns sexp[1]

        if sexp[2] and sexp[2][0] == :resbody
          if sexp[2][2]
            sexp[2][2] = returns sexp[2][2]
          else
            sexp[2][2] = returns s(:nil)
          end
        end
        sexp
      when :ensure
        sexp[1] = returns sexp[1]
        sexp
      when :begin
        sexp[1] = returns sexp[1]
        sexp
      when :rescue_mod
        sexp[1] = returns sexp[1]
        sexp[2] = returns sexp[2]
        sexp
      when :while
        # sexp[2] = returns(sexp[2])
        sexp
      when :return, :js_return
        sexp
      when :xstr
        sexp[1] = "return #{sexp[1]};" unless /return|;/ =~ sexp[1]
        sexp
      when :dxstr
        sexp[1] = "return #{sexp[1]}" unless /return|;|\n/ =~ sexp[1]
        sexp
      when :if
        sexp[2] = returns(sexp[2] || s(:nil))
        sexp[3] = returns(sexp[3] || s(:nil))
        sexp
      else
        s(:js_return, sexp).tap { |s|
          s.source = sexp.source
        }
      end
    end

    def handle_block_given_call(sexp)
      @scope.uses_block!
      if @scope.block_name
        fragment("(#{@scope.block_name} !== nil)", sexp)
      elsif scope = @scope.find_parent_def and scope.block_name
        fragment("(#{scope.block_name} !== nil)", sexp)
      else
        fragment("false", sexp)
      end
    end
  end
end
