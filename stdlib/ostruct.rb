class OpenStruct
  def initialize(hash = nil)
    @table = {}

    hash.each_pair {|key, value|
      @table[key.to_sym] = value
    } if hash
  end

  def [](name)
    @table[name.to_sym]
  end

  def []=(name, value)
    @table[name.to_sym] = value
  end

  def method_missing(name, *args)
    if name.end_with? '='
      @table[name[0 .. -2].to_sym] = args[0]
    else
      @table[name.to_sym]
    end
  end

  def each_pair
    return enum_for :each_pair unless block_given?

    @table.each_pair {|pair|
      yield pair
    }
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

  def hash
    @table.hash
  end

  def inspect
    "#<#{self.class}: #{each_pair.map {|name, value|
      "#{name}=#{self[name].inspect}"
    }.join(" ")}>"
  end
end
