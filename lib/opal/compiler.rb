require 'opal/lexer'
require 'opal/grammar'
require 'opal/target_scope'
require 'opal/version'
require 'opal/fragment'
require 'opal/nodes'
require 'set'

module Opal
  class Compiler
    # Generated code gets indented with two spaces on each scope
    INDENT = '  '

    # All compare method nodes - used to optimize performance of
    # math comparisons
    COMPARE = %w[< > <= >=]

    # defines a compiler option, also creating method of form 'name?'
    def self.compiler_option(name, default_value)
      mid = [true, false].include?(default_value) ? "#{name}?" : name

      define_method(mid) do
        @options.fetch(name) { default_value }
      end
    end

    # used for __FILE__ directives as well as finding relative require()
    compiler_option :file, '(file)'

    # adds method stubs for all used methods in file
    compiler_option :method_missing, true

    # adds an arity check to every method definition
    compiler_option :arity_check, false

    # checks every constant access, delagating to const_missing if needed
    compiler_option :const_missing, false

    # compile top level local vars with support for irb style vars
    compiler_option :irb, false

    # how to handle dynamic requires (:error, :warning, :ignore)
    compiler_option :dynamic_require_severity, :error

    attr_reader :result, :fragments

    # Current scope
    attr_reader :scope

    # Any helpers required by this file
    attr_reader :helpers

    # Method calls made in this file
    attr_reader :method_calls

    # Current case_stmt
    attr_reader :case_stmt

    def initialize
      @line = 1
      @indent = ''
      @unique = 0
      @options = {}

      @method_calls = Set.new
      @helpers = Set.new([:breaker, :slice])
    end

    # Compile some ruby code to a string.
    def compile(source, options = {})
      @source = source
      @options.update options

      @sexp = Grammar.new.parse(@source, self.file)

      top_node = Nodes::TopNode.new(@sexp, :expr, self)
      @fragments = top_node.compile_to_fragments.flatten

      @result = @fragments.map(&:code).join('')
    end

    def source_map
      Opal::SourceMap.new(@fragments, '(file)')
    end

    # This is called when a parsing/processing error occurs. This
    # method simply appends the filename and curent line number onto
    # the message and raises it.
    def error(msg)
      raise SyntaxError, "#{msg} :#{@file}:#{@line}"
    end

    # This is called when a parsing/processing warning occurs. This
    # method simply appends the filename and curent line number onto
    # the message and issues a warning.
    def warning(msg)
      warn "#{msg} :#{@file}:#{@line}"
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
      sexp = Sexp.new(parts)
      sexp.line = @line
      sexp
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
      @helpers << name
    end

    # Every time the parser enters a new scope, this is called with
    # the scope type as an argument. Valid types are `:top` for the
    # top level/file scope; `:class`, `:module` and `:sclass` for the
    # obvious ruby classes/modules; `:def` and `:iter` for methods
    # and blocks respectively.
    #
    # This method just pushes a new instance of `Opal::Scope` onto the
    # stack, sets the new scope as the `@scope` variable, and yields
    # the given block. Once the block returns, the old scope is put
    # back on top of the stack.
    def in_scope(type)
      return unless block_given?

      parent = @scope
      @scope = TargetScope.new(type, self).tap { |s| s.parent = parent }
      yield @scope

      @scope = parent
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
      if handler = handlers[sexp.type]
        @line = sexp.line
        return handler.new(sexp, level, self).compile_to_fragments
      else
        raise "Unsupported sexp: #{sexp.type}"
      end
    end

    def handlers
      @handlers ||= Opal::Nodes::Base.handlers
    end

    # Handle "special" method calls, e.g. require(). Subclasses can override
    # this method. If this method returns nil, then the method will continue
    # to be generated by CallNode.
    def handle_call(sexp)
      case sexp[2]
      when :require
        return handle_require(sexp[3][1])
      when :autoload
        if @scope.class_scope?
          return handle_require(sexp[3][2])
        end
      else
        nil
      end
    end

    # An array of requires used in this file
    def requires
      @requires ||= []
    end

    def handle_require(sexp)
      str = handle_require_sexp sexp
      requires << str unless str.nil?
      fragment("", sexp)
    end

    def handle_require_sexp(sexp)
      type = sexp.shift

      if type == :str
        return sexp[0]
      elsif type == :call
        recv, meth, args = sexp
        parts = args[1..-1].map { |s| handle_require_sexp s }

        if recv == [:const, :File]
          if meth == :expand_path
            return handle_expand_path(*parts)
          elsif meth == :join
            return handle_expand_path parts.join("/")
          elsif meth == :dirname
            return handle_expand_path parts[0].split("/")[0...-1].join("/")
          end
        end
      end

      case @dynamic_require_severity
      when :error
        error "Cannot handle dynamic require"
      when :warning
        warning "Cannot handle dynamic require"
      end
    end

    def handle_expand_path(path, base = '')
      "#{base}/#{path}".split("/").inject([]) do |p, part|
        if part == ''
          # we had '//', so ignore
        elsif part == '..'
          p.pop
        else
          p << part
        end

        p
      end.join "/"
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
    # sexps can just be added into a s(:return) sexp, so that is the
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
          s.line = sexp.line
        }
      end
    end

    def js_block_given(sexp, level)
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
