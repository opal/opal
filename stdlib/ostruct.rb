# use_strict: true
# frozen_string_literal: true

class OpenStruct
  def initialize(hash = nil)
    @table = {}

    if hash
      hash.each_pair do |key, value|
        @table[new_ostruct_member(key)] = value
      end
    end
  end

  def [](name)
    @table[name.to_sym]
  end

  def []=(name, value)
    @table[new_ostruct_member(name)] = value
  end

  def method_missing(name, *args)
    if args.length > 2
      raise NoMethodError.new("undefined method `#{name}' for #<OpenStruct>", name)
    end
    if name.end_with? '='
      if args.length != 1
        raise ArgumentError, 'wrong number of arguments (0 for 1)'
      end
      @table[new_ostruct_member(name[0..-2])] = args[0]
    else
      @table[name.to_sym]
    end
  end

  def respond_to_missing?(mid, include_private = false) # :nodoc:
    mname = mid.to_s.chomp('=').to_sym
    @table&.key?(mname) || super
  end

  def each_pair
    return enum_for :each_pair unless block_given?

    @table.each_pair do |pair|
      yield pair
    end
  end

  def ==(other)
    return false unless other.is_a?(OpenStruct)

    @table == other.instance_variable_get(:@table)
  end

  def ===(other)
    return false unless other.is_a?(OpenStruct)

    @table === other.instance_variable_get(:@table)
  end

  def eql?(other)
    return false unless other.is_a?(OpenStruct)

    @table.eql? other.instance_variable_get(:@table)
  end

  def to_h
    @table.dup
  end

  def to_n
    @table.to_n
  end

  def hash
    @table.hash
  end

  attr_reader :table

  def delete_field(name)
    sym = name.to_sym
    begin
      singleton_class.__send__(:remove_method, sym, "#{sym}=")
    rescue NameError
    end
    @table.delete sym
  end

  def new_ostruct_member(name)
    name = name.to_sym
    unless respond_to?(name)
      define_singleton_method(name) { @table[name] }
      define_singleton_method("#{name}=") { |x| @table[name] = x }
    end
    name
  end

  `var ostruct_ids;`

  def inspect
    %x{
      var top = (ostruct_ids === undefined),
          ostruct_id = #{__id__};
    }
    begin
      result = "#<#{self.class}"
      %x{
        if (top) {
          ostruct_ids = {};
        }
        if (ostruct_ids.hasOwnProperty(ostruct_id)) {
          return result + ' ...>';
        }
        ostruct_ids[ostruct_id] = true;
      }

      result += ' ' if @table.any?

      result += each_pair.map do |name, value|
        "#{name}=#{value.inspect}"
      end.join ', '

      result += '>'

      result
    ensure
      %x{
        if (top) {
          ostruct_ids = undefined;
        }
      }
    end
  end

  alias to_s inspect
end
