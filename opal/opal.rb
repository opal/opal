require 'core/runtime'
require 'core/module'
require 'core/class'
require 'core/basic_object'
require 'core/kernel'
require 'core/nil_class'
require 'core/boolean'
require 'core/error'
require 'core/regexp'
require 'core/comparable'
require 'core/enumerable'
require 'core/enumerator'
require 'core/array'
require 'core/hash'
require 'core/string'
require 'core/match_data'
require 'core/encoding'
require 'core/numeric'
require 'core/proc'
require 'core/method'
require 'core/range'
require 'core/time'
require 'core/struct'
require 'core/io'
require 'core/main'

# regexp matches
$& = $~ = $` = $' = nil

# stub library path
$: = []
$" = []

# split lines
$/ = "\n"
$, = " "

ARGV = []
ARGF = Object.new
ENV  = {}

$VERBOSE = false
$DEBUG   = false
$SAFE    = 0

RUBY_PLATFORM       = 'opal'
RUBY_ENGINE         = 'opal'
RUBY_VERSION        = '1.9.3'
RUBY_ENGINE_VERSION = '0.5.1'
RUBY_RELEASE_DATE   = '2013-08-13'

module Opal
  def self.coerce_to(object, type, method)
    return object if type === object

    unless object.respond_to? method
      raise TypeError, "no implicit conversion of #{object.class} into #{type}"
    end

    object.__send__ method
  end

  def self.coerce_to!(object, type, method)
    coerced = coerce_to(object, type, method)

    unless type === coerced
      raise TypeError, "can't convert #{object.class} into #{type} (#{object.class}##{method} gives #{coerced.class}"
    end

    coerced
  end

  def self.try_convert(object, type, method)
    return object if type === object

    if object.respond_to? method
      object.__send__ method
    end
  end

  def self.truthy?(value)
    if value
      true
    else
      false
    end
  end

  def self.falsy?(value)
    if value
      false
    else
      true
    end
  end

  def self.destructure(args)
    %x{
      if (args.length == 1) {
        return args[0];
      }
      else if (args._isArray) {
        return args;
      }
      else {
        return $slice.call(args);
      }
    }
  end
end
