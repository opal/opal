# The {Enumerable} module.
module Enumerable
  def all?
    each {|obj|
      return false unless block_given? ? yield(obj) : obj
    }

    true
  end

  def any?
    each {|obj|
      return true if block_given? ? yield(obj) : obj
    }

    false
  end

  # TODO: #chunk

  def collect
    return enum_for :collect unless block_given?

    result = []
    each do |*args|
      result.push(yield *args)
    end

    result
  end

  alias_method :map, :collect

  def count (*args, &block)
    if args.length > 1
      raise ArgumentError, "wrong number of arguments (#{args.length} for 1)"
    end

    result = 0

    if args.length == 0 && !block
      block = proc { true }
    else
      block = proc { |obj| obj == args.first }
    end

    each {|obj|
      result += 1 if block.call(obj)
    }

    result
  end

  # TODO: #cycle

  def detect (if_none = nil)
    return enum_for :detect, if_none unless block_given?

    each {|obj|
      return obj if yield(obj)
    }

    if_none
  end

  alias_method :find, :detect

  def drop (number)
    result  = []
    current = 0

    each {|obj|
      result.push(obj) if number < current
      current += 1
    }

    result
  end

  def drop_while
    return enum_for :drop_while unless block_given?

    result = []
    add    = false

    each {|obj|
      add = true if !add && !yield(obj)

      result.push(obj) if add
    }

    result
  end

  # TODO: #each_cons
  # TODO: #each_entry
  # TODO: #each_slice

  def each_with_index (*args)
    return enum_for :each_with_index, *args unless block_given?

    index = 0

    each(*args) {|obj|
      yield obj, index

      index += 1
    }
  end

  def each_with_object (object)
    return enum_for :each_with_object, obj unless block_given?

    each {|*args|
      yield *args #, object
    }

    object
  end

  def find_index (*args)
    if args.length > 1
      raise ArgumentError, "wrong number of arguments (#{args.length} for 1)"
    end

    return enum_for :find_index unless args.length == 1 || block_given?

    if args.length == 1
      block = proc { |obj| obj == args.first }
    end

    each_with_index {|obj, index|
      return index if yield(obj)
    }

    nil
  end

  def first (number = nil)
    result = []

    if number
      current = 0

      each {|obj|
        break if number < current

        result.push(obj)

        current += 1
      }
    else
      each {|obj|
        result = obj
        break
      }
    end

    result
  end

  # TODO: flat_map

  def grep (pattern)
    result = []

    each {|obj|
      result.push obj if pattern === obj && (!block_given? || yield(obj))
    }

    result
  end

  def group_by
    return enum_for :group_by unless block_given?

    result = {}

    each {|obj|
      result[yield obj] = obj
    }

    result
  end

  def include? (object)
    any? {|obj|
      obj == object
    }
  end

  alias_method :member?, :include?

=begin
  def inject (*args, &block)
    if args > 2
      raise ArgumentError, "wrong number of arguments (#{args.length} for 0..2)"
    end

    initial = nil

    if args.length == 1
      if args.first.is_a?(Symbol)
        block = -> a, b { a.__send__ args.first }
      else
        initial = args.first
      end
    else
      initial, method = args
    end

    result = initial || first

    each {|obj|
      result = block.call(result, initial)
    }
  end

  alias_method :reduce, :inject
=end

  # Returns an array containing the items in the receiver.
  #
  # @example
  #
  #     (1..4).to_a       # => [1, 2, 3, 4]
  #     [1, 2, 3].to_a    # => [1, 2, 3]
  #
  # @return [Array]
  def to_a
    result = []

    each {|obj|
      result.push obj
    }

    result
  end

  alias_method :entries, :to_a
end

