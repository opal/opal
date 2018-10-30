class Random
  MATH_RANDOM_GENERATOR = `{
    new_seed: function() { return 0; },
    reseed: function(seed) { return {}; },
    rand: function($rng) { return Math.random(); }
  }`

  self.generator = MATH_RANDOM_GENERATOR
end
