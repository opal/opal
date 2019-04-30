require 'corelib/random/MersenneTwister'

class Random
  `var MAX_INT = Number.MAX_SAFE_INTEGER || Math.pow(2, 53) - 1`

  MERSENNE_TWISTER_GENERATOR = `{
    new_seed: function() { return Math.round(Math.random() * MAX_INT); },
    reseed: function(seed) { return MersenneTwister.init(seed); },
    rand: function(mt) { return MersenneTwister.genrand_real(mt); }
  }`

  self.generator = MERSENNE_TWISTER_GENERATOR
end
