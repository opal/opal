class String
  `var ERROR = "String#%s not supported. Mutable String methods are not supported in Opal.";`

  def <<(*)
    raise NotImplementedError, `ERROR` % '<<'
  end

  def capitalize!(*)
    raise NotImplementedError, `ERROR` % 'capitalize!'
  end

  def chomp!(*)
    raise NotImplementedError, `ERROR` % 'chomp!'
  end

  def chop!(*)
    raise NotImplementedError, `ERROR` % 'chop!'
  end

  def downcase!(*)
    raise NotImplementedError, `ERROR` % 'downcase!'
  end

  def gsub!(*)
    raise NotImplementedError, `ERROR` % 'gsub!'
  end

  def lstrip!(*)
    raise NotImplementedError, `ERROR` % 'lstrip!'
  end

  def next!(*)
    raise NotImplementedError, `ERROR` % 'next!'
  end

  def reverse!(*)
    raise NotImplementedError, `ERROR` % 'reverse!'
  end

  def slice!(*)
    raise NotImplementedError, `ERROR` % 'slice!'
  end

  def squeeze!(*)
    raise NotImplementedError, `ERROR` % 'squeeze!'
  end

  def strip!(*)
    raise NotImplementedError, `ERROR` % 'strip!'
  end

  def sub!(*)
    raise NotImplementedError, `ERROR` % 'sub!'
  end

  def succ!(*)
    raise NotImplementedError, `ERROR` % 'succ!'
  end

  def swapcase!(*)
    raise NotImplementedError, `ERROR` % 'swapcase!'
  end

  def tr!(*)
    raise NotImplementedError, `ERROR` % 'tr!'
  end

  def tr_s!(*)
    raise NotImplementedError, `ERROR` % 'tr_s!'
  end

  def upcase!(*)
    raise NotImplementedError, `ERROR` % 'upcase!'
  end
end

module Kernel
  `var ERROR = "Object freezing is not supported by Opal";`

  def freeze
    if `OPAL_CONFIG.freezing`
      warn `ERROR`
    else
      raise NotImplementedError, `ERROR`
    end
  end

  def frozen?
    if `OPAL_CONFIG.freezing`
      warn `ERROR`
    else
      raise NotImplementedError, `ERROR`
    end
  end
end

module Kernel
  `var ERROR = "Object tainting is not supported by Opal";`

  def taint
    if `OPAL_CONFIG.tainting`
      warn `ERROR`
    else
      raise NotImplementedError, `ERROR`
    end
  end

  def untaint
    if `OPAL_CONFIG.tainting`
      warn `ERROR`
    else
      raise NotImplementedError, `ERROR`
    end
  end

  def tainted?
    if `OPAL_CONFIG.tainting`
      warn `ERROR`
    else
      raise NotImplementedError, `ERROR`
    end
  end
end

module Marshal
  `var ERROR = "Marshalling is not supported by Opal";`

  module_function

  def dump(*)
    raise NotImplementedError, `ERROR`
  end

  def load(*)
    raise NotImplementedError, `ERROR`
  end

  def restore(*)
    raise NotImplementedError, `ERROR`
  end
end
