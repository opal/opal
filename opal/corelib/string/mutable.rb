# use_strict: true
# helpers: prop

# In short, how do we make a string mutable:
#
# 1. We ensure all String calls in Opal actually call toString() or
#    valueOf() before resolution.
# 2. We override those methods using a replace call - but only if
#    we do it on a boxed string, otherwise it wouldn't be possible.

# This means, that for all intents and purposes you are always able
# to use a String as you have used it before this support. BUT if you
# want to send a mutated string to JavaScript, you must either call
# `#to_n` from the `native` module, or use toString() yourself. OR you
# need to ensure that the library you are using is doing it. A word
# of warning: using the mutable string functions WILL NOT be more
# performant in Opal as it is in Ruby.

class String
  # return_nil argument is private
  def replace(other, return_nil = false)
    %x{
      if (typeof self === 'string') {
        #{raise FrozenError, "can't modify frozen String: #{inspect}"}
      }

      var oldstr = self.toString();
      var newstr = other.toString();

      if (oldstr === newstr) {
        return return_nil ? nil : self;
      }

      var to_string = function() {
        return other;
      }

      $prop(self, "toString", to_string);
      $prop(self, "valueOf", to_string);

      return self;
    }
  end

  def <<(other)
    replace(self + other)
  end

  def capitalize!
    replace(capitalize, true)
  end

  def chomp!(*args)
    replace(chomp(*args), true)
  end

  def chop!
    replace(chop, true)
  end

  def downcase!(*)
    replace(downcase(*args), true)
  end

  def gsub!(*args, &block)
    replace(gsub(*args, &block), true)
  end

  def lstrip!
    replace(lstrip, true)
  end

  def succ!
    replace(succ)
  end

  alias next! succ!

  def reverse!(*)
    replace(reverse)
  end

  def slice!(*)
    raise NotImplementedError
  end

  def squeeze!(*args)
    replace(squeeze(*args), true)
  end

  def strip!
    replace(strip, true)
  end

  def sub!(*)
    replace(sub(*args, &block), true)
  end

  def swapcase!
    replace(swapcase, true)
  end

  def tr!(*args)
    replace(tr(*args), true)
  end

  def tr_s!(*args)
    replace(tr_s(*args), true)
  end

  def upcase!(*)
    replace(upcase, true)
  end

  # TODO: Support for codepoints
  def concat(*strs)
    replace(([self] + strs).join)
  end

  # TODO: Support for codepoints
  def prepend(*strs)
    replace((strs + [self]).join)
  end

  def []=(*)
    raise NotImplementedError
  end

  def clear(*)
    replace('')
  end

  def encode!(*args)
    replace(encode(*args))
  end

  def unicode_normalize!(*args)
    replace(unicode_normalize(*args))
  end
end