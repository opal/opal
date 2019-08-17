# frozen_string_literal: true

require 'opal/rewriters/base'
require 'opal/regexp_anchors'

module Opal
  module Rewriters
    class JsReservedWords < Base
      # Reserved javascript keywords - we cannot create variables with the
      # same name (ref: http://stackoverflow.com/a/9337272/601782)
      ES51_RESERVED_WORD = /#{REGEXP_START}(?:do|if|in|for|let|new|try|var|case|else|enum|eval|false|null|this|true|void|with|break|catch|class|const|super|throw|while|yield|delete|export|import|public|return|static|switch|typeof|default|extends|finally|package|private|continue|debugger|function|arguments|interface|protected|implements|instanceof)#{REGEXP_END}/.freeze

      # ES3 reserved words that aren’t ES5.1 reserved words
      ES3_RESERVED_WORD_EXCLUSIVE = /#{REGEXP_START}(?:int|byte|char|goto|long|final|float|short|double|native|throws|boolean|abstract|volatile|transient|synchronized)#{REGEXP_END}/.freeze

      # Prototype special properties.
      PROTO_SPECIAL_PROPS = /#{REGEXP_START}(?:constructor|displayName|__proto__|__parent__|__noSuchMethod__|__count__)#{REGEXP_END}/.freeze

      # Prototype special methods.
      PROTO_SPECIAL_METHODS = /#{REGEXP_START}(?:hasOwnProperty|valueOf)#{REGEXP_END}/.freeze

      # Immutable properties of the global object
      IMMUTABLE_PROPS = /#{REGEXP_START}(?:NaN|Infinity|undefined)#{REGEXP_END}/.freeze

      # Doesn't take in account utf8
      BASIC_IDENTIFIER_RULES = /#{REGEXP_START}[$_a-z][$_a-z\d]*#{REGEXP_END}/i.freeze

      # Defining a local function like Array may break everything
      RESERVED_FUNCTION_NAMES = /#{REGEXP_START}(?:Array)#{REGEXP_END}/.freeze

      def self.valid_name?(name)
        BASIC_IDENTIFIER_RULES =~ name && !(
          ES51_RESERVED_WORD =~ name ||
          ES3_RESERVED_WORD_EXCLUSIVE =~ name ||
          IMMUTABLE_PROPS =~ name
        )
      end

      def self.valid_ivar_name?(name)
        !(PROTO_SPECIAL_PROPS =~ name || PROTO_SPECIAL_METHODS =~ name)
      end

      def fix_var_name(name)
        self.class.valid_name?(name) ? name : "#{name}$".to_sym
      end

      def fix_ivar_name(name)
        self.class.valid_ivar_name?(name.to_s[1..-1]) ? name : "#{name}$".to_sym
      end

      def on_lvar(node)
        name, _ = *node
        node = node.updated(nil, [fix_var_name(name)])
        super(node)
      end

      def on_lvasgn(node)
        name, value = *node

        node =
          if value
            node.updated(nil, [fix_var_name(name), value])
          else
            node.updated(nil, [fix_var_name(name)])
          end

        super(node)
      end

      def on_ivar(node)
        name, _ = *node
        node = node.updated(nil, [fix_ivar_name(name)])
        super(node)
      end

      def on_ivasgn(node)
        name, value = *node

        node =
          if value
            node.updated(nil, [fix_ivar_name(name), value])
          else
            node.updated(nil, [fix_ivar_name(name)])
          end

        super(node)
      end

      # Restarg is a special case
      # because it may have no name
      # def m(*); end
      def on_restarg(node)
        name, _ = *node

        if name
          node = node.updated(nil, [fix_var_name(name)], meta: { arg_name: name })
        end

        node
      end

      def on_argument(node)
        node = super(node)
        name, value = *node
        fixed_name = fix_var_name(name)
        new_children = value ? [fixed_name, value] : [fixed_name]

        node.updated(nil, new_children, meta: { arg_name: name })
      end
    end
  end
end
