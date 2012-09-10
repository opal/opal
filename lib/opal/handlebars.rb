require 'opal/handlebars_grammar'
require 'strscan'

module Opal
  class Handlebars < Racc::Parser
    def initialize()
    end

    def compile(source, file='(file)')
      parsed = parse source, file
      generate parsed
    end
    
    def parse(source, file='(file)')
      @scanner   = StringScanner.new source
      @lex_state = :content 
      do_parse
    end

    def s(*parts)
      parts
    end

    def next_token
      scanner = @scanner

      if @lex_state == :mustache
        if scanner.scan(/\{\{>/)
          return [:OPEN_PARTIAL, scanner.matched]
        elsif scanner.scan(/\{\{#/)
          return [:OPEN_BLOCK, scanner.matched]
        elsif scanner.scan(/\{\{\//)
          return [:OPEN_ENDBLOCK, scanner.matched]
        elsif scanner.scan(/\{\{\^/)
          return [:OPEN_INVERSE, scanner.matched]
        elsif scanner.scan(/\{\{\s*else/)
          return [:OPEN_INVERSE, scanner.matched]
        elsif scanner.scan(/\{\{\{/)
          return [:OPEN_UNESCAPED, scanner.matched]
        elsif scanner.scan(/\{\{\&/)
          return [:OPEN_UNESCPAED, scanner.matched]
        elsif scanner.scan(/\{\{\![\s\S]*?\}\}/)
          return [:COMMENT, scanner.matched[3..-5]]
        elsif scanner.scan(/\{\{/)
          return [:OPEN, scanner.matched]
        elsif scanner.scan(/[0-9]+/)
          return [:INTEGER, scanner.matched]
        elsif scanner.scan(/[a-zA-Z0-9_$-]+/)
          return [:ID, scanner.matched]
        elsif scanner.scan(/"(\"["]|[^"])*"/)
          return [:STRING, scanner.matched[1..-2]]
        elsif scanner.scan(/'(\'[']|[^'])*'/)
          return [:STRING, scanner.matched[1..-2]]
        elsif scanner.scan(/=/)
          return [:EQUALS, scanner.matched]
        elsif scanner.scan(/[\/.]/)
          return [:SEP, scanner.matched]
        elsif scanner.scan(/\s+/)
          # skip whitspace
          return next_token
        elsif scanner.scan(/\}\}/)
          
          @lex_state = :content
          return [:CLOSE, scanner.matched]
        end
      else # @lex_state == :content
        if scanner.check(/\{\{/)
          @lex_state = :mustache
          return next_token
        elsif scanner.scan(/[^\{\{]+|./)
          @lex_state = :mustache
          return [:CONTENT, scanner.matched]
        end
      end

      return [false, false] if scanner.eos?
      raise "Unexpected content in parsing stream #{scanner.peek(5).inspect}"
    end

    def generate(tree)
      process tree
    end

    def process(sexp)
      type = sexp.shift
      send "process_#{type}", sexp
    end

    def process_program(sexp)
      sexp[0].map { |p| process(p) }.join ''
    end

    def process_content(sexp)
      push_text('"' + escape_text(sexp[0]) + '"')
    end

    def process_mustache(sexp)
      handle_prop(sexp)
    end

    def handle_prop(sexp)
      args, hash = sexp
      prop = args.shift[1][0]

      params = args.map { |p| process(p) }
      params.unshift "'#{prop}'"
      params << process(hash) if hash

      "handle_tag(#{params.join ', '})\n"
    end

    def process_id(sexp)
      "handle_tag('#{sexp[0][0]}')"
    end

    def process_string(sexp)
      sexp[0].inspect
    end

    def process_hash(sexp)
      "{ #{sexp[0].map { |h| handle_hash_part(h) }.join ', '} }"
    end

    def handle_hash_part(part)
      "#{part[0].inspect} => #{process(part[1])}"
    end

    def escape_text(text)
      text.gsub(/\\/, '\\\\').gsub(/\"/, '\\\"').gsub(/\n/, '\\n').gsub(/\r/, '\\r')
    end

    def push_text(text)
      "push(#{text})\n"
    end
  end
end