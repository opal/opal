module Opal
  module Keywords

    class KeywordTable
      attr_accessor :name, :id, :state

      def initialize(name, id, state)
        @name = name
        @id = id
        @state = state
      end
    end

    KEYWORDS = [
      ["__LINE__",  [:LINE,     :LINE],       :expr_end],
      ["__FILE__",  [:FILE,     :FILE],       :expr_end],
      ["alias",     [:ALIAS,    :ALIAS],      :expr_fname],
      ["and",       [:AND,      :AND],        :expr_beg],
      ["begin",     [:BEGIN,    :BEGIN],      :expr_beg],
      ["break",     [:BREAK,    :BREAK],      :expr_mid],
      ["case",      [:CASE,     :CASE],       :expr_beg],
      ["class",     [:CLASS,    :CLASS],      :expr_class],
      ["def",       [:DEF,      :DEF],        :expr_fname],
      ["defined?",  [:DEFINED,  :DEFINED],    :expr_arg],
      ["do",        [:DO,       :DO],         :expr_beg],
      ["else",      [:ELSE,     :ELSE],       :expr_beg],
      ["elsif",     [:ELSIF,    :ELSIF],      :expr_beg],
      ["end",       [:END,      :END],        :expr_end],
      ["ensure",    [:ENSURE,   :ENSURE],     :expr_beg],
      ["false",     [:FALSE,    :FALSE],      :expr_end],
      ["if",        [:IF,       :IF_MOD],     :expr_beg],
      ["module",    [:MODULE,   :MODULE],     :expr_beg],
      ["nil",       [:NIL,      :NIL],        :expr_end],
      ["next",      [:NEXT,     :NEXT],       :expr_mid],
      ["not",       [:NOT,      :NOT],        :expr_beg],
      ["or",        [:OR,       :OR],         :expr_beg],
      ["redo",      [:REDO,     :REDO],       :expr_end],
      ["rescue",    [:RESCUE,   :RESCUE_MOD], :expr_mid],
      ["return",    [:RETURN,   :RETURN],     :expr_mid],
      ["self",      [:SELF,     :SELF],       :expr_end],
      ["super",     [:SUPER,    :SUPER],      :expr_arg],
      ["then",      [:THEN,     :THEN],       :expr_beg],
      ["true",      [:TRUE,     :TRUE],       :expr_end],
      ["undef",     [:UNDEF,    :UNDEF],      :expr_fname],
      ["unless",    [:UNLESS,   :UNLESS_MOD], :expr_beg],
      ["until",     [:UNTIL,    :UNTIL_MOD],  :expr_beg],
      ["when",      [:WHEN,     :WHEN],       :expr_beg],
      ["while",     [:WHILE,    :WHILE_MOD],  :expr_beg],
      ["yield",     [:YIELD,    :YIELD],      :expr_arg]
    ].map { |decl| KeywordTable.new(*decl) }

    def self.map
      unless @map
        @map = {}
        KEYWORDS.each { |k| @map[k.name] = k }
      end
      @map
    end

    def self.keyword(kw)
      map[kw]
    end
  end
end
