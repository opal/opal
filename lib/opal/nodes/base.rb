require 'opal/nodes/helpers'
require 'parser/source/map'
require 'parser/source/map/definition'


$h = {}

module Opal
  module Nodes
    class Base
      include Helpers


      
      def self.handlers
        @handlers ||= {}
      end

      def self.handle(*types)
        types.each do |type|
          Base.handlers[type] = self
        end
      end

      def self.children(*names)
        names.each_with_index do |name, idx|
          define_method(name) do
            @sexp.children[idx]
          end
        end
      end

      def self.truthy_optimize?
        false
      end

      attr_reader :compiler, :type

      def onbegin(x)
        #print x + "\n"
        if not x.nil?
          @source_line="b|#{@sexp.loc.class}|#{@type}|#{x}"
        end
      end

      def onnode(x)
        #print x
      end

      def position(n,x)
        if not x.nil?
          @source_line= "p|#{@sexp.loc.class}|#{@type}|#{x}"
        end
      end

      def setline(x)
        #print n+ "\n"
        if not x.nil?
          @source_line= "l|#{@sexp.loc.class}|#{@type}|#{x}"
        end
      end

      def initialize(sexp, level, compiler)
        @sexp = sexp
        @type = sexp.type
        @level = level
        @compiler = compiler
        @source_line = "NONE" # TODO

        #        print "Loc: #{@sexp.loc} CLS: #{sexp.loc.class} Type: #{@type}\n"

        t = "#{sexp.loc.class}"
        
        if  not $h.key?(t)
          #print $h
          
          #print "// when '#{t}'\n"
          $h[t]=1
        end
              
        
        if true
          case "#{sexp.loc.class}"
              
          when 'NilClass'
          # nothing
          when 'Parser::Source::Map'
            #position("expression",sexp.loc.expression)
            #onnode(sexp.loc.node)
            
          when 'Parser::Source::Map::Condition'
            # position("keyword",sexp.loc.keyword)
            # position("end",sexp.loc.end)
            # position("else",sexp.loc.else)
            # onbegin(sexp.loc.begin)
            # position("expression",sexp.loc.expression)
            # onnode(sexp.loc.node)
          when 'Parser::Source::Map::Operator'
            #position("operator",sexp.loc.operator)
            #position("expression",sexp.loc.expression)
            #onnode(sexp.loc.node)
          when 'Parser::Source::Map::Constant'
            #position("name",sexp.loc.name)
            #position("::",sexp.loc.double_colon)
            #position("expression",sexp.loc.expression)
            #onnode(sexp.loc.node)
          when 'Parser::Source::Map::Ternary'
            #position(":",sexp.loc.colon)
            #position("?",sexp.loc.question)
            #position("expression",sexp.loc.expression)
            #onnode(sexp.loc.node)
          when 'Parser::Source::Map::Keyword'
            #position("keyword",sexp.loc.keyword)
            #position("end",sexp.loc.end)
            #onbegin(sexp.loc.begin)
            #position("expression",sexp.loc.expression)
            #onnode(sexp.loc.node)
          when 'Parser::Source::Map::RescueBody'
            position("keyword",sexp.loc.keyword)
            position("assoc",sexp.loc.assoc)
            onbegin(sexp.loc.begin)
            position("expression",sexp.loc.expression)
            onnode(sexp.loc.node)
          when 'Parser::Source::Map::Collection'
            #array
            # position("end",sexp.loc.end)
            # position("begin",sexp.loc.begin)
            # position("expression",sexp.loc.expression)
            # onnode(sexp.loc.node)
            
          when 'Parser::Source::Map::Send'
            #position("dot",sexp.loc.dot)
            #position("selector",sexp.loc.selector)
            #position("end",sexp.loc.end)
            #onbegin(sexp.loc.begin)
            #position("expression",sexp.loc.expression)
            #onnode(sexp.loc.node)

          when 'Parser::Source::Map::Definition'
            # useful!
            # position("keyword",sexp.loc.keyword)
            # position("operator",sexp.loc.operator)
            # position("name",sexp.loc.name)
            # position("end",sexp.loc.end)
            # position("expression",sexp.loc.expression)
            # onnode(sexp.loc.node)

          when 'Parser::Source::Map::Variable'
            #position("name",sexp.loc.name)
            #position("expression",sexp.loc.expression)
            #onnode(sexp.loc.node)
          when 'Parser::Source::Map::Heredoc'
            position("body",sexp.loc.heredoc_body)
            position("end",sexp.loc.heredoc_end)
            position("expression",sexp.loc.expression)
            onnode(sexp.loc.node)
            
          else
            if sexp.loc
              if sexp.loc.begin 
                position("begin",sexp.loc.begin)
              end
              if sexp.loc.end
                position("end",sexp.loc.end)
              end
            end
            if sexp.line
              setline("#{sexp.line}:#{sexp.column}")
            end
          end
        end
      end

      def source_line
        @source_line
      end

      def source_line=(sl)
        @source_line=sl
      end

      def children
        @sexp.children
      end

      def compile_to_fragments
        return @fragments if defined?(@fragments)

        @fragments = []
        self.compile
        @fragments

      end

      def compile
        raise "Not Implemented"
      end

      def push(*strs)
        strs.each do |str|
          str = fragment(str) if str.is_a?(String)
          @fragments << str
        end
      end

      def unshift(*strs)
        strs.reverse.each do |str|
          str = fragment(str) if str.is_a?(String)
          @fragments.unshift str
        end
      end

      def wrap(pre, post)
        unshift pre
        push post
      end

      def fragment(str)
        Opal::Fragment.new str, scope, @sexp, @source_line
      end

      def error(msg)
        @compiler.error msg
      end

      def scope
        @compiler.scope
      end

      def s(*args)
        @compiler.s(*args)
      end

      def expr?
        @level == :expr
      end

      def recv?
        @level == :recv
      end

      def stmt?
        @level == :stmt
      end

      def process(sexp, level = :expr)
        @compiler.process sexp, level
      end

      def expr(sexp)
        @compiler.process sexp, :expr
      end

      def recv(sexp)
        @compiler.process sexp, :recv
      end

      def stmt(sexp)
        @compiler.process sexp, :stmt
      end

      def expr_or_nil(sexp)
        sexp ? expr(sexp) : "nil"
      end

      def add_local(name)
        scope.add_scope_local name.to_sym
      end

      def add_ivar(name)
        scope.add_scope_ivar name
      end

      def add_gvar(name)
        scope.add_scope_gvar name
      end

      def add_temp(temp)
        scope.add_scope_temp temp
      end

      def helper(name)
        @compiler.helper name
      end

      def with_temp(&block)
        @compiler.with_temp(&block)
      end

      def in_while?
        @compiler.in_while?
      end

      def while_loop
        @compiler.instance_variable_get(:@while_loop)
      end

      def has_rescue_else?
        scope.has_rescue_else?
      end

      def in_ensure(&block)
        scope.in_ensure(&block)
      end

      def in_ensure?
        scope.in_ensure?
      end

      def closest_module_node
        current = scope
        while current && !current.class_scope?
          current = current.parent
        end
        current
      end

      def class_variable_owner
        if closest_module_node
          "$#{closest_module_node.name}"
        else
          "Opal.Object"
        end
      end
    end
  end
end
