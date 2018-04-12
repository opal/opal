# frozen_string_literal: true

require 'set'
require 'opal/parser'
require 'opal/fragment'
require 'opal/nodes'
require 'opal/eof_content'
require 'opal/errors'

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
    COMPARE = %w[< > <= >=].freeze

    def self.module_name(path)
      path = File.join(File.dirname(path), File.basename(path).split('.').first)
      Pathname(path).cleanpath.to_s
    end

    # defines a compiler option, also creating method of form 'name?'
    def self.compiler_option(name, default_value, options = {})
      mid          = options[:as]
      valid_values = options[:valid_values]
      define_method(mid || name) do
        value = @options.fetch(name) { default_value }
        if valid_values && !valid_values.include?(value)
          raise ArgumentError, "invalid value #{value.inspect} for option #{name.inspect} " \
                               "(valid values: #{valid_values.inspect})"
        end
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
    compiler_option :method_missing, true, as: :method_missing?

    # @!method arity_check?
    #
    # adds an arity check to every method definition
    #
    # @return [Boolean]
    compiler_option :arity_check, false, as: :arity_check?

    # @deprecated
    # @!method freezing?
    #
    # stubs out #freeze and #frozen?
    #
    # @return [Boolean]
    compiler_option :freezing, true, as: :freezing?

    # @deprecated
    # @!method tainting?
    #
    # stubs out #taint, #untaint and #tainted?
    compiler_option :tainting, true, as: :tainting?

    # @!method irb?
    #
    # compile top level local vars with support for irb style vars
    compiler_option :irb, false, as: :irb?

    # @!method dynamic_require_severity
    #
    # how to handle dynamic requires (:error, :warning, :ignore)
    compiler_option :dynamic_require_severity, :ignore, valid_values: %i[error warning ignore]

    # @!method requirable?
    #
    # Prepare the code for future requires
    compiler_option :requirable, false, as: :requirable?

    # @!method inline_operators?
    #
    # are operators compiled inline
    compiler_option :inline_operators, true, as: :inline_operators?

    compiler_option :eval, false, as: :eval?

    # @!method enable_source_location?
    #
    # Adds source_location for every method definition
    compiler_option :enable_source_location, false, as: :enable_source_location?

    # @!method parse_comments?
    #
    # Adds comments for every method definition
    compiler_option :parse_comments, false, as: :parse_comments?

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

    # Comments from the source code
    attr_reader :comments

    def initialize(source, options = {})
      @source = source
      @indent = ''
      @unique = 0
      @options = options
      @comments = Hash.new([])
      @case_stmt = nil
    end

    # Compile some ruby code to a string.
    #
    # @return [String] javascript code
    def compile
      parse

      @fragments = process(@sexp).flatten

      @result = @fragments.map(&:code).join('')
    end

    def parse
      @buffer = ::Opal::Source::Buffer.new(file, 1)
      @buffer.source = @source

      @parser = Opal::Parser.default_parser

      begin
        sexp, comments, tokens = @parser.tokenize(@buffer)
      rescue ::Opal::Error => error
        backtrace = error.backtrace
        if error.respond_to? :location
          line = error.location.line
          backtrace << "#{file}:#{line}:in #{error.location.expression.source_line}"
        end
        raise ::Opal::SyntaxError, error.message, backtrace
      rescue ::Parser::SyntaxError => error
        backtrace = error.backtrace
        raise ::Opal::SyntaxError, error.message, backtrace
      end

      @sexp = s(:top, sexp || s(:nil))
      @comments = ::Parser::Source::Comment.associate_locations(sexp, comments)
      @eof_content = EofContent.new(tokens, @source).eof
    end

    # Returns a source map that can be used in the browser to map back to
    # original ruby code.
    #
    # @param source_file [String] optional source_file to reference ruby source
    # @return [Opal::SourceMap]
    def source_map(source_file = nil)
      Opal::SourceMap.new(@fragments, source_file || file)
    end

    # Any helpers required by this file. Used by {Opal::Nodes::Top} to reference
    # runtime helpers that are needed. These are used to minify resulting
    # javascript by keeping a reference to helpers used.
    #
    # @return [Set<Symbol>]
    def helpers
      @helpers ||= Set.new(%i[breaker slice])
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
      raise ::Opal::SyntaxError, "#{msg} -- #{file}:#{line}"
    end

    # This is called when a parsing/processing warning occurs. This
    # method simply appends the filename and curent line number onto
    # the message and issues a warning.
    def warning(msg, line = nil)
      warn "warning: #{msg} -- #{file}:#{line}"
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
    def s(type, *children)
      ::Opal::AST::Node.new(type, children)
    end

    def fragment(str, scope, sexp = nil)
      Fragment.new(str, scope, sexp)
    end

    # Used to generate a unique id name per file. These are used
    # mainly to name method bodies for methods that use blocks.
    def unique_temp(name)
      name = name.to_s
      if name && !name.empty?
        name = "_#{name}"
               .gsub('?', '$q')
               .gsub('!', '$B')
               .gsub('=', '$eq')
               .gsub('<', '$lt')
               .gsub('>', '$gt')
               .gsub(/[^\w\$]/, '$')
      end
      unique = (@unique += 1)
      "TMP#{name}_#{unique}"
    end

    # Use the given helper
    def helper(name)
      helpers << name
    end

    # To keep code blocks nicely indented, this will yield a block after
    # adding an extra layer of indent, and then returning the resulting
    # code after reverting the indent.
    def indent
      indent = @indent
      @indent += INDENT
      @space = "\n#{@indent}"
      res = yield
      @indent = indent
      @space = "\n#{@indent}"
      res
    end

    # Temporary varibales will be needed from time to time in the
    # generated code, and this method will assign (or reuse) on
    # while the block is yielding, and queue it back up once it is
    # finished. Variables are queued once finished with to save the
    # numbers of variables needed at runtime.
    def with_temp
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
      result = indent { yield }
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
      return fragment('', scope) if sexp.nil?

      if handler = handlers[sexp.type]
        return handler.new(sexp, level, self).compile_to_fragments
      else
        error "Unsupported sexp: #{sexp.type}"
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
      when :undef
        # undef :method_name always returns nil
        returns s(:begin, sexp, s(:nil))
      when :break, :next, :redo
        sexp
      when :yield
        sexp.updated(:returnable_yield, nil)
      when :when
        *when_sexp, then_sexp = *sexp
        sexp.updated(nil, [*when_sexp, returns(then_sexp)])
      when :rescue
        body_sexp, *resbodies, else_sexp = *sexp

        resbodies = resbodies.map do |resbody|
          returns(resbody)
        end

        if else_sexp
          else_sexp = returns(else_sexp)
        end

        sexp.updated(
          nil, [
            returns(body_sexp),
            *resbodies,
            else_sexp
          ]
        )
      when :resbody
        klass, lvar, body = *sexp
        sexp.updated(nil, [klass, lvar, returns(body)])
      when :ensure
        rescue_sexp, ensure_body = *sexp
        sexp = sexp.updated(nil, [returns(rescue_sexp), ensure_body])
        s(:js_return, sexp)
      when :begin, :kwbegin
        # Wrapping last expression with s(:js_return, ...)
        *rest, last = *sexp
        sexp.updated(nil, [*rest, returns(last)])
      when :while, :until, :while_post, :until_post
        sexp
      when :return, :js_return, :returnable_yield
        sexp
      when :xstr
        sexp.updated(nil, [s(:js_return, *sexp.children)])
      when :if
        cond, true_body, false_body = *sexp
        sexp.updated(
          nil, [
            cond,
            returns(true_body),
            returns(false_body)
          ]
        )
      else
        s(:js_return, sexp).updated(
          nil,
          nil,
          location: sexp.loc,
        )
      end
    end

    def handle_block_given_call(sexp)
      @scope.uses_block!
      if @scope.block_name
        fragment("(#{@scope.block_name} !== nil)", scope, sexp)
      elsif (scope = @scope.find_parent_def) && scope.block_name
        fragment("(#{scope.block_name} !== nil)", scope, sexp)
      else
        fragment('false', scope, sexp)
      end
    end
  end
end
