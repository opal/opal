var RubyHash;

// Returns new hash with values passed from ruby
VM.H = function() {
  var hash = new RubyHash.$a(), key, val, args = ArraySlice.call(arguments);
  var assocs = hash.map = {};
  hash.none = Qnil;

  for (var i = 0, ii = args.length; i < ii; i++) {
    key = args[i];
    val = args[i + 1];
    i++;
    assocs[key] = [key, val];
  }

  return hash;
};

function hash_s_create() {
  return VM.H.apply(null, ArraySlice.call(arguments));
}

function hash_alloc() {
  return VM.H();
}

function hash_new() {
  return VM.H();
}

function hash_equal(other) {
  var self = this;
  if (self === other) return true;
  if (!other.map) return false;

  var map = self.map, map2 = other.map;

  for (var assoc in map) {
    if (!map2[assoc]) return false;
    var obj = map[assoc][1], obj2 = map2[assoc][1];
    if (!obj.m$eq$(obj2)) return false;
  }

  return true;
}

function hash_aref(key) {
  var hash = key, val;
  if (val = this.map[hash]) return val[1];
  return this.none;
}

function hash_aset(key, value) {
  var hash = key;
  this.map[hash] = [key, value];
  return value;
}

function hash_assoc(object) {
  for (var assoc in this.map) {
    var bucket = this.map[assoc];
    if (bucket[0].m$eq$(object)) return [bucket[0], bucket[1]];
  }
  return nil;
}

function hash_clear() {
  this.map = {};
  return this;
}

function hash_clone() {
  var result = VM.H(), map = this.map, map2 = result.map;
  for (var assoc in map) map2[assoc] = [map[assoc][0], map[assoc][1]];
  return result;
}

function hash_default() {
  return this.none;
}

function hash_set_default(object) {
  return this.none = object;
}

function hash_default_proc() {
  return this.proc;
}

function hash_set_default_proc(proc) {
  this.proc = proc;
}

function hash_delete(key) {
  var hash = key, bucket, ret;
  if (bucket = this.map[hash]) {
    ret = bucket[1];
    delete this.map[hash];
    return ret;
  }
  return this.none;
}

function hash_delete_if() {
  var self = this, iterator = hash_delete_if.proc, map = self.map, bucket;
  if (!iterator) return self.m$enum_for("delete_if");

  var context = iterator.$s, val;
  hash_delete_if.proc = 0;

  for (var assoc in map) {
    bucket = map[assoc];
    if ((val = iterator.call(context, bucket[0], bucket[1])) === breaker) return breaker.$v;
    if (val !== false && val !== nil) delete map[assoc];
  }
  return self;
}

function hash_each() {
  var self = this, iterator = hash_each.proc, map = self.map, bucket;
  if (!iterator) return self.m$enum_for("each");

  var context = iterator.$S;
  hash_each.proc = 0;

  for (var assoc in map) {
    bucket = map[assoc];
    if (iterator.call(context, bucket[0], bucket[1]) === breaker)
      return breaker.$v;
  }
  return self;
}

function hash_each_key() {
  var self = this, iterator = hash_each_key.proc, map = self.map;
  if (!iterator) return self.m$enum_for("each_key");

  var context = iterator.$S;
  hash_each_key.proc = 0;

  for (var assoc in map) {
    if (iterator.call(context, map[assoc][0]) === breaker) return breaker.$v;
  }
  return self;
}

function hash_each_value() {
  var self = this, iterator = hash_each_value.proc, map = self.map;
  if (!iterator) return self.m$enum_for("each_value");

  var context = iterator.$S;
  hash_each_value.proc = 0;

  for (var assoc in map) {
    if (iterator.call(context, map[assoc][1]) === breaker) return breaker.$v;
  }
  return self;
}

function hash_empty_p() {
  for (var assoc in this.map) return false;
  return true;
}

function hash_fetch(key, defaults) {
  var self = this, map = self.map, bucket = map[key];
  if (bucket) return bucket[1];

  if (hash_fetch.proc) {
    var iterator = hash_fetch.proc, val, context = iterator.$S;
    hash_fetch.proc = 0;

    if ((val = iterator.call(context, key)) === breaker) return breaker.$v;
    return val;
  }

  if (defaults !== undefined) return defaults;
  rb_raise(rb_eKeyError, 'key not found');
}

function hash_flatten(level) {
  var self = this, map = self.map, result = [];
  for (var assoc in map) {
    var bucket = map[assoc], key = bucket[0], value = bucket[1];
    result.push(key);

    if (value.$f & T_ARRAY) {
      if (level === undefined || level === 1) result.push(value);
      else result = result.concat(value.m$flatten(level - 1));
    }
    else {
      result.push(value);
    }
  }
  return result;
}

function hash_has_key(key) {
  return !!this.map[key];
}

function hash_has_value(value) {
  for (var assoc in this.map) {
    if (this.map[assoc][1].m$eq$(value)) return true;
  }
  return false;
}

function hash_hash() {
  return this.$id;
}

function hash_inspect() {
  var self = this, parts = [], map = self.map;
  for (var assoc in map) {
    var bucket = map[assoc];
    parts.push(bucket[0].m$inspect() + '=>' + bucket[1].m$inspect());
  }
  return '{' + parts.join(', ') + '}';
}

function hash_invert() {
  var self = this, map = self.map, result = VM.H(), map2 = result.map;
  for (var assoc in map) {
    var bucket = map[assoc];
    map2[bucket[1]] = [bucket[0], bucket[1]];
  }
  return result;
}

function hash_key(object) {
  for (var assoc in this.map) {
    var bucket = this.map[assoc];
    if (object.m$eq$(bucket[1])) return bucket[0];
  }
  return nil;
}

function hash_keys() {
  var result = [];
  for (var assoc in this.map) result.push(this.map[assoc][0]);
  return result;
}

function hash_length() {
  var length = 0;
  for (var assoc in this.map) length++;
  return length;
}

function hash_merge(other) {
  var self = this, map = self.map, result = VM.H(), result_map = result.map;

  for (var assoc in map) {
    var bucket = map[assoc];
    result_map[assoc] = [bucket[0], bucket[1]];
  }

  map = other.map;

  for (var assoc in map) {
    var bucket = map[assoc];
    result_map[assoc] = [bucket[0], bucket[1]];
  }

  return result;
}

function hash_update(other) {
  var self = this, map = self.map, map2 = other.map;

  for (var assoc in map2) {
    var bucket = map2[assoc]
    map[assoc] = [bucket[0], bucket[1]];
  }
  return self;
}

function hash_rassoc(object) {
  var self = this, map = self.map;
  for (var assoc in map) {
    var bucket = map[assoc];
    if (bucket[1].m$eq$(object)) return [bucket[0], bucket[1]];
  }
  return nil;
}

function hash_replace(other) {
  var self = this, map = self.map = {};
  for (var assoc in other.map) {
    var bucket = other.map[assoc];
    map[assoc] = [bucket[0], bucket[1]];
  }
  return self;
}

function hash_to_a() {
  var self = this, map = self.map, ary = [];
  for (var assoc in map) {
    var bucket = map[assoc];
    ary.push([bucket[0], bucket[1]]);
  }
  return ary;
}

function hash_to_hash() {
  return this;
}

function hash_values() {
  var self = this, map = self.map, values = [];
  for (var assoc in map) values.push(map[assoc][1]);
  return values;
}

function init_hash() {
  RubyHash = define_class(rb_cObject, 'Hash', rb_cObject);
  rb_include_module(RubyHash, RubyEnumerable);

  define_singleton_method(RubyHash, 'm$aref$', hash_s_create);
  define_singleton_method(RubyHash, 'm$allocate', hash_alloc);
  define_singleton_method(RubyHash, 'm$new', hash_new);

  define_methods(RubyHash, {
    'm$eq$': hash_equal,
    'm$aref$': hash_aref,
    'm$aset$': hash_aset,
    'm$assoc': hash_assoc,
    'm$clear': hash_clear,
    'm$clone': hash_clone,
    'm$default': hash_default,
    'm$default$e': hash_set_default,
    'm$default_proc': hash_default_proc,
    'm$default_proc$e': hash_set_default_proc,
    'm$delete': hash_delete,
    'm$delete_if': hash_delete_if,
    'm$each': hash_each,
    'm$each_key': hash_each_key,
    'm$each_pair': hash_each,
    'm$each_value': hash_each_value,
    'm$empty$p': hash_empty_p,
    'm$eql$p': hash_equal,
    'm$fetch': hash_fetch,
    'm$flatten': hash_flatten,
    'm$has_key$p': hash_has_key,
    'm$has_value$p': hash_has_value,
    'm$hash': hash_hash,
    'm$include$p': hash_has_key,
    'm$inspect': hash_inspect,
    'm$invert': hash_invert,
    'm$key': hash_key,
    'm$key$p': hash_has_key,
    'm$keys': hash_keys,
    'm$length': hash_length,
    'm$member$p': hash_has_key,
    'm$merge': hash_merge,
    'm$merge$b': hash_update,
    'm$rassoc': hash_rassoc,
    'm$replace': hash_replace,
    'm$size': hash_length,
    'm$to_a': hash_to_a,
    'm$to_hash': hash_to_hash,
    'm$to_s': hash_inspect,
    'm$update': hash_update,
    'm$values': hash_values
  });
}
