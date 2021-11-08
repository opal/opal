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
    ::Kernel.raise ::TypeError, 'expected Array or nil' unless Array === keys
    return {} if keys.length > values.length
    out = {}
    keys.each do |key|
      should_break = case key
                     when ::Integer
                       values.length < key
                     when ::Symbol # Or String? Doesn't matter, we're in Opal.
                       !members.include?(key)
                     end
      break if should_break
      out[key] = self[key]
    end
    out
  end
end

class NoMatchingPatternError < ::StandardError; end
