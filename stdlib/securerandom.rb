module SecureRandom
  extend Random::Formatter

  %x{
    var gen_random_bytes;

    if ((Opal.global.crypto   && Opal.global.crypto.getRandomValues) ||
        (Opal.global.msCrypto && Opal.global.msCrypto.getRandomValues)) {
      // This method is available in all non-ancient web browsers.

      var crypto = Opal.global.crypto || Opal.global.msCrypto;
      gen_random_bytes = function(count) {
        var storage = new Uint8Array(count);
        crypto.getRandomValues(storage);
        return storage;
      };
    }
    else if (Opal.global.crypto && Opal.global.crypto.randomBytes) {
      // This method is available in Node.js

      gen_random_bytes = function(count) {
        return Opal.global.crypto.randomBytes(count);
      };
    }
    else {
      // Let's dangerously polyfill this interface with our MersenneTwister
      // xor native JS Math.random xor something about current time...
      // That's hardly secure, but the following warning should provide a person
      // deploying the code a good idea on what he should do to make his deployment
      // actually secure.
      // It's possible to interface other libraries by adding an else if above if
      // that's really desired.

      #{warn 'Can\'t get a Crypto.getRandomValues interface or Crypto.randomBytes.' \
             'The random values generated with SecureRandom won\'t be ' \
             'cryptographically secure'}

      gen_random_bytes = function(count) {
        var storage = new Uint8Array(count);
        for (var i = 0; i < count; i++) {
          storage[i] = #{rand(0xff)} ^ Math.floor(Math.random() * 256);
          storage[i] ^= +(new Date())>>#{rand(0xff)}&0xff;
        }
        return storage;
      }
    }
  }

  def self.bytes(bytes = nil)
    gen_random(bytes)
  end

  def self.gen_random(count = nil)
    count = Random._verify_count(count)
    out = ''
    %x{
      var bytes = gen_random_bytes(#{count});
      for (var i = 0; i < #{count}; i++) {
        out += String.fromCharCode(bytes[i]);
      }
    }
    out.encode('ASCII-8BIT')
  end
end
