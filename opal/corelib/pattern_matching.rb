# A "userland" implementation of pattern matching for Opal

class PatternMatching
  def self.call(from, pattern)
    pm = new(from, pattern)
    pm.match || (return false)
    pm.returns
  end

  def initialize(from, pattern)
    @from, @pattern = from, pattern
    @returns = []
  end

  attr_reader :returns

  def match(from = @from, pattern = @pattern)
    if pattern == :var
      @returns << from
      true
    else # Pattern is otherwise an Array
      type, *args = *pattern

      case type
      when :save # from =>
        @returns << from
        match(from, args[0])
      when :lit # 3, 4, :a, (1..), ... (but also ^a)
        args[0] === from
      when :any # a | b
        args.any? { |arg| match(from, arg) }
      when :all # Array(1) which works as Array & [1] (& doesn't exist though...)
        args.all? { |arg| match(from, arg) }
      when :array # [...]
        fixed_size, array_size, array_match = *args
        return false unless from.respond_to? :deconstruct
        a = from.deconstruct
        return false if fixed_size && a.length != array_size
        return false if a.length < array_size

        skip_elems = 0
        skip_rests = 0

        array_match.each_with_index.all? do |elem, i|
          type, *args = elem
          case type
          when :rest
            skip_elems = a.size - array_size
            skip_rests = 1
            match(a[i...i + skip_elems], args[0]) if args[0] # :save?
            true
          else
            match(a[i + skip_elems - skip_rests], elem)
          end
        end
      when :find # [*, a, b, *]
        raise NotImplementedError, 'Find pattern is not yet implemented'
      when :hash # {...}
        any_size, hash_match = *args

        hash_match = hash_match.to_h

        return false unless from.respond_to? :deconstruct_keys

        if any_size && any_size != true # a => {a:, **other}
          a = from.deconstruct_keys(nil) #          ^^^^^^^
        else
          a = from.deconstruct_keys(hash_match.keys)
        end

        hash_match.all? do |k, v|
          return false unless a.key? k
          match(a[k], v)
        end || (return false)

        if any_size && any_size != true
          match(a.except(*hash_match.keys), args[0])
        elsif !any_size
          return false unless a.except(*hash_match.keys).empty?
        end

        true
      end
    end
  end
end

class Array
  def deconstruct
    self
  end
end

class Hash
  def deconstruct_keys(_)
    self
  end
end

class Struct
  alias deconstruct to_a
  # This function is specified in a very weird way...
  def deconstruct_keys(keys)
    return to_h if keys.nil?
    raise TypeError, 'expected Array or nil' unless Array === keys
    return {} if keys.length > values.length
    out = {}
    keys.each do |key|
      should_break = case key
                     when Integer
                       values.length < key
                     when Symbol # Or String? Doesn't matter, we're in Opal.
                       !members.include?(key)
                     end
      break if should_break
      out[key] = self[key]
    end
    out
  end
end

class NoMatchingPatternError < StandardError; end
