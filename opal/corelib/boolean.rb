# use_strict: true
# frozen_string_literal: true

class Boolean < `Boolean`
  `Opal.defineProperty(self.$$prototype, '$$is_boolean', true)`

  %x{
    var properties = ['$$class', '$$meta'];

    for (var i = 0; i < properties.length; i++) {
      Object.defineProperty(self.$$prototype, properties[i], {
        configurable: true,
        enumerable: false,
        get: function() {
          return this == true  ? Opal.TrueClass :
                 this == false ? Opal.FalseClass :
                                 Opal.Boolean;
        }
      });
    }
  }

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{name}"
    end

    undef :new
  end

  def __id__
    `self.valueOf() ? 2 : 0`
  end

  alias object_id __id__

  def !
    `self != true`
  end

  def &(other)
    `(self == true) ? (other !== false && other !== nil) : false`
  end

  def |(other)
    `(self == true) ? true : (other !== false && other !== nil)`
  end

  def ^(other)
    `(self == true) ? (other === false || other === nil) : (other !== false && other !== nil)`
  end

  def ==(other)
    `(self == true) === other.valueOf()`
  end

  alias equal? ==
  alias eql? ==

  def singleton_class
    `self.$$meta`
  end

  def to_s
    `(self == true) ? 'true' : 'false'`
  end

  def dup
    self
  end

  def clone(freeze: true)
    self
  end

  # See: https://github.com/opal/opal/issues/2230
  #
  # This is a hack that allows you to add methods to TrueClass and FalseClass.
  # Do note, that while true and false have a correct $$class (it's either
  # TrueClass or FalseClass), their prototype is `Boolean.$$prototype`, which
  # basically means that when calling `true.something` we actually call
  # `Boolean#something` instead of `TrueClass#something`. So using
  # method_missing we dispatch it to `TrueClass/FalseClass#something` correctly.
  #
  # The downside is that a correct implementation would also allow us to override
  # the methods defined on Boolean, but our implementation doesn't allow that,
  # unless you define them on Boolean and not on TrueClass/FalseClass.
  def method_missing(method, *args, &block)
    `var body = self.$$class.$$prototype['$' + #{method}]`
    super unless `typeof body !== 'undefined' && !body.$$stub`
    `Opal.send(self, body, #{args}, #{block})`
  end

  def respond_to_missing?(method, _include_all = false)
    `var body = self.$$class.$$prototype['$' + #{method}]`
    `typeof body !== 'undefined' && !body.$$stub`
  end
end

class TrueClass < Boolean; end
class FalseClass < Boolean; end

TRUE  = true
FALSE = false
