# helpers: falsy

require 'corelib/random/formatter'

class Random
  attr_reader :seed, :state

  def self._verify_count(count)
    %x{
      if ($falsy(count)) count = 16;
      if (typeof count !== "number") count = #{`count`.to_int};
      if (count < 0) #{::Kernel.raise ::ArgumentError, 'negative string size (or size too big)'};
      count = Math.floor(count);
      return count;
    }
  end

  def initialize(seed = ::Random.new_seed)
    seed = ::Opal.coerce_to!(seed, ::Integer, :to_int)
    @state = seed
    reseed(seed)
  end

  def reseed(seed)
    @seed = seed
    `self.$rng = Opal.$$rand.reseed(seed)`
  end

  def self.new_seed
    `Opal.$$rand.new_seed()`
  end

  def self.rand(limit = undefined)
    DEFAULT.rand(limit)
  end

  def self.srand(n = ::Random.new_seed)
    n = ::Opal.coerce_to!(n, ::Integer, :to_int)

    previous_seed = DEFAULT.seed
    DEFAULT.reseed(n)
    previous_seed
  end

  def self.urandom(size)
    ::SecureRandom.bytes(size)
  end

  def ==(other)
    return false unless Random === other

    seed == other.seed && state == other.state
  end

  def bytes(length)
    length = ::Random._verify_count(length)

    ::Array.new(length) { rand(255).chr }.join.encode('ASCII-8BIT')
  end

  def self.bytes(length)
    DEFAULT.bytes(length)
  end

  def rand(limit = undefined)
    random_number(limit)
  end

  # Not part of the Ruby interface (use #random_number for portability), but
  # used by Random::Formatter as a shortcut, as for Random interface the float
  # RNG is primary.
  def random_float
    %x{
      self.state++;
      return Opal.$$rand.rand(self.$rng);
    }
  end

  def self.random_float
    DEFAULT.random_float
  end

  def self.generator=(generator)
    `Opal.$$rand = #{generator}`

    if const_defined? :DEFAULT
      DEFAULT.reseed
    else
      const_set :DEFAULT, new(new_seed)
    end
  end
end

require 'corelib/random/mersenne_twister'
