#!/usr/bin/env ruby -wKU

class Racc2JS
  
  def initialize(source, output = nil)
    @source = source
    @output = output || 
          File.join(File.dirname(source), File.basename(source, '.*') + '.js')
    
    @racc_output = File.join(
          File.dirname(source), File.basename(source, '.*') + '.rb')
  end
  
  def generate
    puts "generating racc parser..."
    `racc --output-file=#@racc_output #@source`
    puts "loading generated parser.."
    self.class.module_eval File.read(File.expand_path(@racc_output))
    # we rely on only constant under our class being our new generated parser..
    parser = self.class.constants[0]
    raise "no suitable parser found in #@racc_output" unless parser
    puts "using parser: #{parser}"
    @parser_name = parser.to_s
    @parser = self.class.const_get(parser)
    
    @parser_output = []
    handle_parser_runtime
    handle_racc_arg
    handle_racc_actions
    
    # write output to our destination
    File.open(@output, 'w') { |o| o.puts pre + @parser_output.join('') + post }
    
    # remove temp ruby file
    File.delete @racc_output
  end
  
  # pre code
  def pre
    %Q[var #@parser_name = (function() {\n]
  end
  
  # post code
  def post
    %Q[\n   return parser;
      })();
      
      if (typeof require !== 'undefined' && typeof module !== 'undefined') {
        exports.#@parser_name = #@parser_name;
      }
    ]
  end
  
  # add parser runtime to @parser_output
  def handle_parser_runtime
    source = File.read(File.join(File.dirname(__FILE__), 'parser.js'))
    @parser_output << source
  end
  
  # handle racc table
  def handle_racc_arg
    racc_arg = @parser::Racc_arg
    
    @parser_output << "parser.Racc_arg = [\n"
    
    # puts racc_arg
    racc_arg.each_with_index do |arg, idx|
      @parser_output.push "," if idx > 0
      
      case arg
      when Array
        @parser_output << "["
        
        arg.each_with_index do |ary_item, ary_idx|
          @parser_output.push "," if ary_idx > 0
          @parser_output.push ruby_to_javascript ary_item
        end
        
        @parser_output << "]"
      when Hash
        @parser_output << "{"
        done = false
        arg.each do |key, value|
          @parser_output.push "," if done
          done = true
          
          @parser_output.push key.to_s.inspect
          @parser_output.push ": "
          @parser_output.push ruby_to_javascript(value)
        end
        
        @parser_output << "}"
      else
        @parser_output << ruby_to_javascript(arg)
      end  
    end
    
    @parser_output << "];"
  end
  
  # output ruby values' javascript equivalent
  def ruby_to_javascript(literal)
    case literal
    when Numeric
      literal.to_s
    when NilClass
      # see parser.js - saves space once minimized. - removed.
      'null'
    when String, Symbol
      literal.to_s.inspect
    when true, false
      literal.to_s
    else
      raise "Error: bad native: #{literal}"
    end
  end
  
  # get all method from racc. we get all impl methods, and then output their
  # code to js. we (for now) rely on all methods basically being:
  # 
  #   result = "val[0] + .."
  # 
  # so we assign result a string, which we can then use to output js..hacky, but
  # only way (for now).
  def handle_racc_actions
    # get all methods and unique them.
    reduce_table = @parser::Racc_arg[9].select { |a| Symbol === a }.uniq!
    # remove racc_error and _reduce_none
    reduce_table.delete(:racc_error)
    reduce_table.delete(:_reduce_none)
    # we need a parser to use
    parser = @parser.new
    reduce_table.each do |reduction|
      code = parser.send(reduction, nil, nil, nil)
      @parser_output << %Q[
        parser.prototype.#{reduction} = function(val, result) {
          #{code}
          return result;
        };]
    end
  end
end

#
# bin
#
if $0 == __FILE__
  if ARGV.empty?
    raise "no filename given"
  elsif ARGV.length == 1
    Racc2JS.new(ARGV[0]).generate
  else
    Racc2JS.new(ARGV[0], ARGV[1]).generate
  end
end

