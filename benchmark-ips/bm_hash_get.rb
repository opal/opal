Benchmark.ips do |x|
  %x{
    var $has_own   = Object.hasOwn || $call.bind(Object.prototype.hasOwnProperty);

    function hash_get_new(hash, key) {
      if (key.$$is_string) {
        if (typeof hash.$$smap[key] !== "undefined") {
          return hash.$$smap[key];
        }
        return;
      }
    };

    function hash_get_old(hash, key) {
      if (key.$$is_string) {
        if ($has_own(hash.$$smap, key)) {
          return hash.$$smap[key];
        }
        return;
      }
    };
  }

  h = { value: 12 }

  x.report('old_version') { `hash_get_old(h, 'value')` }
  x.report('new_version') { `hash_get_new(h, 'value')` }

  x.compare!
end
