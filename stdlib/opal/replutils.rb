require 'pp'
require 'stringio'


module REPLUtils
  module_function

  def ls(object)
    methods = imethods = object.methods
    ancestors = object.class.ancestors
    constants = []
    ivs = object.instance_variables
    cvs = []

    if [Class, Module].include? object.class
      imethods = object.instance_methods
      ancestors = object.ancestors
      constants = object.constants
      cvs = object.class_variables
    end

    blue      = ->(i) { "\e[1;34m#{i}\e[0m" }
    dark_blue = ->(i) { "\e[34m#{i}\e[0m" }

    out = ''
    out = "#{blue['class variables']}: #{cvs.map { |i| dark_blue[i] }.sort.join('  ')}\n" + out unless cvs.empty?
    out = "#{blue['instance variables']}: #{ivs.map { |i| dark_blue[i] }.sort.join('  ')}\n" + out unless ivs.empty?
    ancestors.each do |a|
      im = a.instance_methods(false)
      meths = (im & imethods)
      methods -= meths
      imethods -= meths
      next if meths.empty? || [Object, BasicObject, Kernel, PP::ObjectMixin].include?(a)
      out = "#{blue["#{a.name}#methods"]}: #{meths.sort.join('  ')}\n" + out
    end
    methods &= object.methods(false)
    out = "#{blue['self.methods']}: #{methods.sort.join('  ')}\n" + out unless methods.empty?
    out = "#{blue['constants']}: #{constants.map { |i| dark_blue[i] }.sort.join('  ')}\n" + out unless constants.empty?
    out
  end

  def eval_and_print(func, mode)
    %x{
      var $_result = #{func}();

      if (typeof $_result === 'null') {
        return "=> null";
      }
      else if (typeof $_result === 'undefined') {
        return "=> undefined";
      }
      else if (typeof $_result.$$class === 'undefined') {
        try {
          var json = JSON.stringify($_result, null, 2);
          json = #{ColorPrinter.colorize(`json`)}
          return "=> " + $_result.toString() + " => " + json;
        }
        catch(e) {
          return "=> " + $_result.toString();
        }
      }
      else {
        if (mode == 'ls') {
          return #{ls(`$_result`)};
        }
        else {
          var pretty = #{ColorPrinter.default(`$_result`)};
          // Is it multiline? If yes, add a linebreak
          if (pretty.match(/\n.*?\n/)) pretty = "\n" + pretty;
          return "=> " + pretty;
        }
      }
    }
    `ret`
  rescue Exception => e # rubocop:disable Lint/RescueException
    e.full_message(highlight: true)
  end

  # Slightly based on Pry's implementation
  class ColorPrinter < ::PP
    # Taken from CodeRay
    TOKEN_COLORS = {
      debug: "\e[1;37;44m",

      annotation: "\e[34m",
      attribute_name: "\e[35m",
      attribute_value: "\e[31m",
      binary: {
        self: "\e[31m",
        char: "\e[1;31m",
        delimiter: "\e[1;31m",
      },
      char: {
        self: "\e[35m",
        delimiter: "\e[1;35m"
      },
      class: "\e[1;35;4m",
      class_variable: "\e[36m",
      color: "\e[32m",
      comment: {
        self: "\e[1;30m",
        char: "\e[37m",
        delimiter: "\e[37m",
      },
      constant: "\e[1;34;4m",
      decorator: "\e[35m",
      definition: "\e[1;33m",
      directive: "\e[33m",
      docstring: "\e[31m",
      doctype: "\e[1;34m",
      done: "\e[1;30;2m",
      entity: "\e[31m",
      error: "\e[1;37;41m",
      exception: "\e[1;31m",
      float: "\e[1;35m",
      function: "\e[1;34m",
      global_variable: "\e[1;32m",
      hex: "\e[1;36m",
      id: "\e[1;34m",
      include: "\e[31m",
      integer: "\e[1;34m",
      imaginary: "\e[1;34m",
      important: "\e[1;31m",
      key: {
        self: "\e[35m",
        char: "\e[1;35m",
        delimiter: "\e[1;35m",
      },
      keyword: "\e[32m",
      label: "\e[1;33m",
      local_variable: "\e[33m",
      namespace: "\e[1;35m",
      octal: "\e[1;34m",
      predefined: "\e[36m",
      predefined_constant: "\e[1;36m",
      predefined_type: "\e[1;32m",
      preprocessor: "\e[1;36m",
      pseudo_class: "\e[1;34m",
      regexp: {
        self: "\e[35m",
        delimiter: "\e[1;35m",
        modifier: "\e[35m",
        char: "\e[1;35m",
      },
      reserved: "\e[32m",
      shell: {
        self: "\e[33m",
        char: "\e[1;33m",
        delimiter: "\e[1;33m",
        escape: "\e[1;33m",
      },
      string: {
        self: "\e[31m",
        modifier: "\e[1;31m",
        char: "\e[1;35m",
        delimiter: "\e[1;31m",
        escape: "\e[1;31m",
      },
      symbol: {
        self: "\e[33m",
        delimiter: "\e[1;33m",
      },
      tag: "\e[32m",
      type: "\e[1;34m",
      value: "\e[36m",
      variable: "\e[34m",

      insert: {
        self: "\e[42m",
        insert: "\e[1;32;42m",
        eyecatcher: "\e[102m",
      },
      delete: {
        self: "\e[41m",
        delete: "\e[1;31;41m",
        eyecatcher: "\e[101m",
      },
      change: {
        self: "\e[44m",
        change: "\e[37;44m",
      },
      head: {
        self: "\e[45m",
        filename: "\e[37;45m"
      },
    }

    TOKEN_COLORS[:keyword] = TOKEN_COLORS[:reserved]
    TOKEN_COLORS[:method] = TOKEN_COLORS[:function]
    TOKEN_COLORS[:escape] = TOKEN_COLORS[:delimiter]

    def self.default(obj, width = 79)
      pager = StringIO.new
      pp(obj, pager, width)
      pager.string
    end

    def self.pp(obj, output = $DEFAULT_OUTPUT, max_width = 79)
      queue = ColorPrinter.new(output, max_width, "\n")
      queue.guard_inspect_key { queue.pp(obj) }
      queue.flush
      output << "\n"
    end

    def text(str, max_width = str.length)
      super(ColorPrinter.colorize(str), max_width)
    end

    def self.token(string, *name)
      TOKEN_COLORS.dig(*name) + string + "\e[0m"
    end

    NUMBER = '[+-]?[0-9.]+(?:e[+-][0-9]+|i)?'
    REGEXP = '/.*?/[iesu]*'
    TOKEN_REGEXP = /(\s+|=>|[@$:]?[a-z]\w+|[A-Z]\w+|#{NUMBER}|#{REGEXP}|".*?"|#<.*?[> ]|.)/

    def self.tokenize(str)
      str.scan(TOKEN_REGEXP).map(&:first)
    end

    def self.colorize(str)
      tokens = tokenize(str)

      tokens.map do |tok|
        case tok
        when /^[0-9+-]/
          if /[.e]/ =~ tok
            token(tok, :float)
          else
            token(tok, :integer)
          end
        when /^"/
          token(tok, :string, :self)
        when /^:/
          token(tok, :symbol, :self)
        when /^[A-Z]/
          token(tok, :constant)
        when /^#</, '=', '>'
          token(tok, :keyword)
        when /^\/./
          token(tok, :regexp, :self)
        when 'true', 'false', 'nil'
          token(tok, :predefined_constant)
        else
          tok
        end
      end.join
    end
  end
end
