require 'corelib/pattern_matching/base'

# A "userland" implementation of pattern matching for Opal

class PatternMatching
  def self.call(from, pattern)
    pm = new(from, pattern)
    pm.match || (return nil)
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
        find_match, = *args
        first, *find_match, last = *find_match
        pattern_length = find_match.length

        return false unless from.respond_to? :deconstruct
        a = from.deconstruct
        a_length = a.length
        return false if a_length < pattern_length

        # We will save the backup of returns, to be restored
        # on each iteration to try again.
        returns_backup = @returns.dup

        # Extract the capture info from first and last.
        # Both are of a form [:rest], or [:rest, :var].
        # So our new variables will be either :var, or nil.
        first, last = first[1], last[1]

        # Let's try to match each possibility...
        # [A, B, c, d], [a, B, C, d], [a, b, C, D]
        iterations = a_length - pattern_length + 1

        iterations.times.any? do |skip|
          first_part = a[0, skip]
          content = a[skip, pattern_length]
          last_part = a[skip + pattern_length..-1]

          match(first_part, first) if first
          success = content.each_with_index.all? do |e, i|
            match(e, find_match[i])
          end
          match(last_part, last) if last

          # Match failed. Let's not return anything.
          @returns = returns_backup.dup unless success

          success
        end
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
