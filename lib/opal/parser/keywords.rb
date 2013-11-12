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
      ["__LINE__",  [:k__LINE__,     :k__LINE__],       :expr_end],
      ["__FILE__",  [:k__FILE__,     :k__FILE__],       :expr_end],
      ["alias",     [:kALIAS,    :kALIAS],      :expr_fname],
      ["and",       [:kAND,      :kAND],        :expr_beg],
      ["begin",     [:kBEGIN,    :kBEGIN],      :expr_beg],
      ["break",     [:kBREAK,    :kBREAK],      :expr_mid],
      ["case",      [:kCASE,     :kCASE],       :expr_beg],
      ["class",     [:kCLASS,   :kCLASS],     :expr_class],
      ["def",       [:kDEF,     :kDEF],       :expr_fname],
      ["defined?",  [:kDEFINED, :kDEFINED],   :expr_arg],
      ["do",        [:kDO,       :kDO],         :expr_beg],
      ["else",      [:kELSE,     :kELSE],       :expr_beg],
      ["elsif",     [:kELSIF,    :kELSIF],      :expr_beg],
      ["end",       [:kEND,      :kEND],        :expr_end],
      ["ensure",    [:kENSURE,   :kENSURE],     :expr_beg],
      ["false",     [:kFALSE,    :kFALSE],      :expr_end],
      ["if",        [:kIF,       :kIF_MOD],     :expr_beg],
      ["module",    [:kMODULE,  :kMODULE],    :expr_beg],
      ["nil",       [:kNIL,      :kNIL],        :expr_end],
      ["next",      [:kNEXT,     :kNEXT],       :expr_mid],
      ["not",       [:kNOT,      :kNOT],        :expr_beg],
      ["or",        [:kOR,       :kOR],         :expr_beg],
      ["redo",      [:kREDO,     :kREDO],       :expr_end],
      ["rescue",    [:kRESCUE,  :kRESCUE_MOD], :expr_mid],
      ["return",    [:kRETURN,   :kRETURN],     :expr_mid],
      ["self",      [:kSELF,     :kSELF],       :expr_end],
      ["super",     [:kSUPER,    :kSUPER],      :expr_arg],
      ["then",      [:kTHEN,     :kTHEN],       :expr_beg],
      ["true",      [:kTRUE,     :kTRUE],       :expr_end],
      ["undef",     [:kUNDEF,   :kUNDEF],     :expr_fname],
      ["unless",    [:kUNLESS,   :kUNLESS_MOD], :expr_beg],
      ["until",     [:kUNTIL,    :kUNTIL_MOD],  :expr_beg],
      ["when",      [:kWHEN,     :kWHEN],       :expr_beg],
      ["while",     [:kWHILE,    :kWHILE_MOD],  :expr_beg],
      ["yield",     [:kYIELD,    :kYIELD],      :expr_arg]
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
