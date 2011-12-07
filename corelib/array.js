var RubyArray;

function ary_s_create() {
  var objects = ArraySlice.call(arguments);
  var result  = this.m$allocate();
  result.splice.apply(result, [0, 0].concat(objects));

  return result;
}

function ary_s_allocate() {
  var ary = [];
  ary.$k = this;
  return ary;
}

function ary_s_new() {
  return [];
}

function ary_and(other) {
  var self   = this,
      result = [],
      seen   = [];

  for (var i = 0, length = self.length; i < self.length; i++) {
    var item = self[i],
        hash = item.$h();

    if (seen.indexOf(hash) == -1) {
      for (var j = 0, length2 = other.length; j < length2; j++) {
        var item2 = other[j],
             hash2 = item2.$h();

        if ((hash == hash2) && seen.indexOf(hash) == -1) {
          seen.push(hash);
          result.push(item);
        }
      }
    }
  }

  return result;
}

function ary_times(other) {
  if (typeof other === 'string') {
    return this.join(other);
  }

  var result = [];

  for (var i = 0, length = parseInt(other); i < length; i++) {
    result = result.concat(this);
  }

  return result;
}

function ary_plus(other) {
  return this.slice(0).concat(other.slice());
}

function ary_push(object) {
  this.push(object);
  return this;
}

function ary_cmp(other) {
  var self = this;

  if (self.m$hash() === other.m$hash()) {
    return 0;
  }

  var tmp;

  for (var i = 0, length = self.length; i < length; i++) {
    if (tmp = self[i].m$$cmp(other[i]) != 0) {
       return tmp;
    }
  }

  if (self.length == other.length) {
    return 0;
  }
   else if (self.length > other.length) {
    return 1;
   }
  else {
    return -1;
  }
}

function ary_equal(other) {
  var self = this;

  if (self.length !== other.length) {
    return false;
  }

  for (var i = 0, length = self.length; i < length; i++) {
    if (!self[i].m$eq$(other[i])) {
      return false;
    }
  }

  return true;
}

// TODO: does not yet work with ranges
function ary_aref(index, length) {
  var self = this,
      size = self.length;

  if (index < 0) {
    index += size;
  }

  if (length !== undefined) {
    if (length < 0 || index > size || index < 0) {
      return nil;
    }

    return self.slice(index, index + length);
  }
  else {
    if (index >= size || index < 0) {
      return nil;
    }
    return self[index];
  }
}

// TODO: need to expand functionality
function ary_aset(index, value) {
  var self = this,
      size = self.length;

  if (index < 0) {
    index += size;
  }

  return self[index] = value;
}

function ary_assoc(object) {
  var self = this;

  for (var i = 0, length = self.length; i < length; i++) {
    var item = self[i];

    if (item.length && item[0].m$eq$(object)) {
      return item;
    }
  }

  return nil;
}

function ary_at(index) {
  var self = this;

  if (index < 0) {
    index += self.length;
  }

  if (index < 0 || index >= self.length) {
    return nil;
  }

  return self[index];
}

function ary_clear() {
  this.splice(0);
  return this;
}

function ary_clone() {
  return this.slice(0);
}

function ary_collect() {
  var self = this, iterator = ary_collect.proc;
  if (!iterator) return self.m$enum_for("collect");

  ary_collect.proc = 0;
  var result = [], context = iterator.$S, val;

  for (var i = 0, length = self.length; i < length; i++) {
    if ((val = iterator.call(context, self[i])) === breaker) {
      return breaker.$v;
    }

    result[i] = val;
  }

  return result;
}

function ary_collect_bang() {
  var self = this, iterator = ary_collect_bang.proc;
  if (!iterator) return self.m$enum_for("collect!");

  ary_collect_bang.proc = 0;
  var val, context = iterator.$S;

  for (var i = 0, length = self.length; i < length; i++) {
    if ((val = iterator.call(context, self[i])) === breaker) {
      return breaker.$v;
    }

    self[i] = val;
  }

  return self;
}

function ary_compact() {
  var self = this, result = [];

  for (var i = 0, length = self.length; i < length; i++) {
    var item = self[i];

    if (item !== nil) {
      result.push(item);
    }
  }

  return result;
}

function ary_compact_bang() {
  var self = this, size = self.length;

  for (var i = 0, length = self.length; i < length; i++) {
    if (self[i] === nil) {
      self.splice(i, 1);
      length--;
      i--;
    }
  }

  return size === self.length ? nil : self;
}

function ary_concat(other) {
  for (var i = 0, length = other.length; i < length; i++) {
    this.push(other[i]);
  }
  return this;
}

function ary_count(object) {
  var self = this, result = 0;
  if (object === undefined) return self.length;

  for (var i = 0, length = self.length; i < length; i++) {
    if (self[i].m$eq$(object)) result++;
  }

  return result;
}

function ary_delete(object) {
  var self = this, size = self.length;

  for (var i = 0, length = size; i < length; i++) {
    if (self[i].m$eq$(object)) {
      self.splice(i, 1);
      length--;
      i--;
    }
  }

  return size === self.length ? nil : object;
}

function ary_delete_at(index) {
  var self = this;
  if (index < 0) index += self.length;
  if (index < 0 || index >= self.length) return nil;

  var result = self[index];
  self.splice(index, 1);
  return result;
}

function ary_delete_if() {
  var self = this, iterator = ary_delete_if.proc;
  if (!iterator) return self.m$enum_for("delete_if");

  var val, context = iterator.$S;
  ary_delete_if.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if ((val = iterator.call(context, self[i])) === breaker) {
      return breaker.$v;
    }

    if (val !== false && val !== nil) {
      self.splice(i, 1);
      length--;
      i--;
    }
  }

  return self;
}

function ary_drop(number) {
  if (number > this.length) return [];
  return this.slice(number);
}

function ary_drop_while() {
  var self = this, iterator = ary_drop_while.proc;
  if (!iterator) return self.m$enum_for("drop_while");

  var context = iterator.$S, val;
  ary_drop_while.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if ((val = iterator.call(context, self[i])) === breaker) {
      return breaker.$v;
    }

    if (val === false || val === nil) return self.slice(i);
  }

  return [];
}

function ary_each() {
  var self = this, iterator = ary_each.proc;
  if (!iterator) return self.m$enum_for("each");

  var context = iterator.$S;
  ary_each.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if (iterator.call(context, self[i]) === breaker) return breaker.$v;
  }

  return self;
}

function ary_each_index() {
  var self = this, iterator = ary_each_index.proc;
  if (!iterator) return self.m$enum_for("each_index");

  var context = iterator.$S;
  ary_each_index.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if (iterator.call(context, i) === breaker) return breaker.$v;
  }

  return self;
}

function ary_each_with_index() {
  var self = this, iterator = ary_each_with_index.proc;
  if (!iterator) return self.m$enum_for("each_with_index");

  var context = iterator.$S;
  ary_each_with_index.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if (iterator.call(context, self[i], i) === breaker) return breaker.$v;
  }

  return self;
}

function ary_empty_p() {
  return this.length === 0;
}

function ary_fetch(index, defaults) {
  var self = this, iterator = ary_fetch.proc, original = index;
  ary_fetch.proc = 0;

  if (index < 0) index += self.length;
  if (index >= 0 && index < self.length) return self[index];
  if (defaults !== undefined) return defaults;

  if (iterator) return iterator.call(iterator.$S, original);
  rb_raise(rb_eIndexError, "Array#fetch");
}

function ary_first(count) {
  if (count !== undefined) return this.slice(0, count);
  if (this.length === 0) return nil;
  return this[0];
}

function ary_flatten(level) {
  var self = this, result = [];

  for (var i = 0, length = self.length; i < length; i++) {
    var item = self[i];

    if (item.$f & T_ARRAY) {
      if (level === undefined)
        result = result.concat(item.m$flatten());
      else if (level === 0)
        result.push(item);
      else
        result = result.concat(item.m$flatten(level - 1));
    }
    else {
      result.push(item);
    }
  }
  return result;
}

// TODO: improve this
function ary_flatten_bang(level) {
  var result = this.m$flatten(level);
  return this.length === result.length ? nil : this.m$clear().m$replace(result);
}

function ary_grep(pattern) {
  var self = this, result = [], item;
  for (var i = 0, length = self.length; i < length; i++) {
    item = self[i];
    if (pattern.m$eqq$(item)) result.push(item);
  }
  return result;
}

function ary_hash() {
  return this.$id || (this.$id = rb_hash_yield++);
}

function ary_includes(member) {
  for (var i = 0, length = this.length; i < length; i++) {
    if (this[i].m$eq$(member)) return true;
  }
  return false;
}

function ary_index(object) {
  var self = this, iterator = ary_index.proc;
  ary_index.proc = 0;

  if (!iterator && object === undefined) return self.m$enum_for("index");

  if (iterator) {
    var context = iterator.$S, val;

    for (var i = 0, length = self.length; i < length; i++) {
      if ((val = iterator.call(context, self[i])) === breaker) return breaker.$v;
      if (val !== false && val !== nil) return i;
    }
  }
  else {
    for (var i = 0, length = self.length; i < length; i++) {
      if (self[i].m$eq$(object)) return i;
    }
  }
  return nil;
}

function ary_inject(initial) {
  var self = this, iterator = ary_inject.proc;
  if (!iterator) return self.m$enum_for("inject");

  var context = iterator.$S, val, i, result;
  ary_inject.proc = 0;

  if (initial === undefined) {
    i = 1; result = self[0];
  }
  else {
    i = 0; result = initial;
  }

  for (var length = self.length; i < length; i++) {
    if ((val = iterator.call(context, result, self[i])) === breaker) return breaker.$v;
    result = val;
  }
  return result;
}

function ary_insert(index) {
  var self = this, objects = ArraySlice.call(arguments, 1);
  if (objects.length > 0) {
    if (index < 0) {
      // insert is different as elements are added AFTER negative index
      index += self.length + 1;
      if (index < 0) rb_raise(rb_eIndexError, index + ' out of bounds');
    }
    // If adding past current length, fill with nils
    if (index > self.length) {
      for (var i = self.length; i < index; i++) self[i] = nil;
    }
    self.splice.apply(self, [index, 0].concat(objects));
  }
  return self;
}

function ary_inspect() {
  var self = this, size = self.length, res = [];
  for (var i = 0; i < size; i++) res[i] = self[i].m$inspect();
  return '[' + res.join(', ') + ']';
}

function ary_join(sep) {
  var self = this, result = [];

  for (var i = 0, length = self.length; i < length; i++)
    result[i] = self[i].m$to_s();

  return result.join(sep === undefined ? '' : sep);
}

function ary_keep_if() {
  var self = this, iterator = ary_keep_if.proc;
  if (!iterator) return self.m$enum_for("keep_if");

  var val, context = iterator.$S;
  ary_keep_if.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if ((val = iterator.call(context, self[i])) === breaker) return breaker.$v;
    if (val === false || val === nil) {
      self.splice(i, 1);
      length--;
      i--;
    }
  }

  return self;
}

function ary_last(count) {
  var self = this, length = self.length;
  if (count === undefined) {
    return length === 0 ? nil : self[length - 1];
  }
  else if (count < 0) {
    rb_raise(rb_eArgError, 'negative count given');
  }
  else {
    if (count > length) count = length;
    return self.slice(length - count, length);
  }
}

function ary_length() {
  return this.length;
}

function ary_pop(count) {
  var self = this, length = self.length;
  if (count === undefined) {
    return length === 0 ? nil : self.pop();
  }
  if (count < 0) rb_raise(rb_eArgError, 'negative count given');
  if (count > length) return self.splice(0);
  return self.splice(length - count, length);
}

function ary_push_m() {
  for (var i = 0, length = arguments.length; i < length; i++) {
    this.push(arguments[i]);
  }
  return this;
}

function ary_rassoc(object) {
  var self = this, item;
  for (var i = 0, length = self.length; i < length; i++) {
    item = self[i];
    if (item.length && item[1] !== undefined) {
      if (item[1].m$eq$(object)) return item;
    }
  }
  return nil;
}

function ary_reject() {
  var self = this, iterator = ary_reject.proc;
  if (!iterator) return self.m$enum_for("reject");

  var context = iterator.$S, result = [], val;
  ary_reject.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if ((val = iterator.call(context, self[i])) === breaker) return breaker.$v;
    if (val === false || val === nil) result.push(self[i]);
  }
  return result;
}

function ary_reject_bang() {
  var self = this, iterator = ary_reject_bang.proc;
  if (!iterator) return self.m$enum_for("reject!");

  var original = self.length, context = iterator.$S, val;
  ary_reject_bang.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    if ((val = iterator.call(context, self[i])) === breaker) return breaker.$v;
    if (val !== false && val !== nil) {
      self.splice(i, 1);
      length--;
      i--;
    }
  }
  return original === self.length ? nil : self;
}

function ary_replace(other) {
  this.m$clear();
  this.m$push.apply(this, other) 
  return this;
}

function ary_reverse() {
  return this.reverse();
}

function ary_reverse_bang() {
  return this.m$replace(this.m$reverse());
}

function ary_reverse_each() {
  var self = this, iterator = ary_reverse_each.proc;
  if (!iterator) return self.m$enum_for("reverse_each");

  var context = iterator.$S;
  ary_reverse_each.proc = 0;

  for (var i = self.length - 1; i >= 0; i--) {
    if (iterator.call(context, self[i]) === breaker) return breaker.$v;
  }
  return self;
}

function ary_rindex(object) {
  var self = this, iterator = ary_rindex.proc;
  if (!iterator && object === undefined) return self.m$enum_for("rindex");

  if (iterator) {
    var context = iterator.$S, val;
    ary_rindex.proc = 0;

    for (var i = self.length - 1; i >= 0; i--) {
      if ((val = iterator.call(context, self[i])) === breaker) return breaker.$v;
      if (val !== false && val !== nil) return i;
    }
  }
  else {
    for (var i = self.length - 1; i >= 0; i--) {
      if (self[i].m$eq$(object)) return i;
    }
  }
  return nil;
}

function ary_select() {
  var self = this, iterator = ary_select.proc;
  if (!iterator) return self.m$enum_for("select");

  var result = [], arg, val, context = iterator.$S;
  ary_select.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    arg = self[i];
    if ((val = iterator.call(context, self[i])) === breaker) return breaker.$v;
    if (val !== false && val !== nil) result.push(arg);
  }
  return result;
}

function ary_select_bang() {
  var self = this, iterator = ary_select_bang.proc;
  if (!iterator) return self.m$enum_for("select!");

  var original = self.length, arg, val, context = iterator.$S;
  ary_select_bang.proc = 0;

  for (var i = 0, length = self.length; i < length; i++) {
    arg = self[i];
    if ((val = iterator.call(context, arg)) === breaker) return breaker.$v;
    if (val === false || val === nil) {
      self.splice(i, 1);
      length--;
      i--;
    }
  }
  return self.length === original ? nil : self;
}

function ary_shift(count) {
  if (count !== undefined) return this.splice(0, count);
  return this.shift();
}

// TODO: does not yet work with ranges
function ary_slice_bang(index, length) {
  var self = this;
  if (index < 0) index += self.length;
  if (index < 0 || index >= self.length) return nil;
  if (length !== undefined) return self.splice(index, index + length);
  return self.splice(index, 1)[0];
}

function ary_take(count) {
  return this.slice(0, count);
}

function ary_take_while() {
  var self = this, iterator = ary_take_while.proc;
  if (!iterator) return self.m$enum_for("take_while");

  var result = [], context = iterator.$S, item, val;

  for (var i = 0, length = self.length; i < length; i++) {
    item = self[i];
    if ((val = iterator.call(context, item)) === breaker) return breaker.$v;
    if (val === false || val === nil) return result;
    result.push(item);
  }
  return result;
}

function ary_to_a() {
  return this;
}

function ary_uniq() {
  var self = this, result = [], seen = {}, item, hash;
  for (var i = 0, length = self.length; i < length; i++) {
    item = self[i]; hash = item.m$hash();
    if (!seen[hash]) {
      seen[hash] = true;
      result.push(item);
    }
  }
  return result;
}

function ary_uniq_bang() {
  var self = this, seen = {}, original = self.length, item, hash;
  for (var i = 0, length = original; i < length; i++) {
    item = self[i]; hash = item.m$hash();
    if (!seen[hash]) seen[hash] = true;
    else {
      self.splice(i, 1);
      length--;
      i--;
    }
  }
  return self.length === original ? nil : self;
}

function ary_unshift() {
  for (var i = arguments.length - 1; i >= 0; i--) this.unshift(arguments[i]);
  return this;
}

function init_array() {
  var RubyArray = rb_bridge_class(Array, T_OBJECT | T_ARRAY, 'Array');

  define_singleton_method(RubyArray, 'm$aref$', ary_s_create);
  define_singleton_method(RubyArray, 'm$allocate', ary_s_allocate);
  define_singleton_method(RubyArray, 'm$new', ary_s_new);

  define_bridge_methods(RubyArray, {
    'm$and$': ary_and,
    'm$mul$': ary_times,
    'm$plus$': ary_plus,
    'm$lshft$': ary_push,
    'm$cmp$': ary_cmp,
    'm$eq$': ary_equal,
    'm$aref$': ary_aref,
    'm$aset$': ary_aset,
    'm$assoc': ary_assoc,
    'm$at': ary_at,
    'm$clear': ary_clear,
    'm$clone': ary_clone,
    'm$collect': ary_collect,
    'm$collect$b': ary_collect_bang,
    'm$compact': ary_compact,
    'm$compact$b': ary_compact_bang,
    'm$concat': ary_concat,
    'm$count': ary_count,
    'm$delete': ary_delete,
    'm$delete_at': ary_delete_at,
    'm$delete_if': ary_delete_if,
    'm$drop': ary_drop,
    'm$drop_while': ary_drop_while,
    'm$dup': ary_clone,
    'm$each': ary_each,
    'm$each_index': ary_each_index,
    'm$each_with_index': ary_each_with_index,
    'm$empty$p': ary_empty_p,
    'm$eql$p': ary_equal,
    'm$fetch': ary_fetch,
    'm$first': ary_first,
    'm$flatten': ary_flatten,
    'm$flatten$b': ary_flatten_bang,
    'm$grep': ary_grep,
    'm$hash': ary_hash,
    'm$include$p': ary_includes,
    'm$index': ary_index,
    'm$inject': ary_inject,
    'm$insert': ary_insert,
    'm$inspect': ary_inspect,
    'm$join': ary_join,
    'm$keep_if': ary_keep_if,
    'm$last': ary_last,
    'm$length': ary_length,
    'm$map': ary_collect,
    'm$map$b': ary_collect_bang,
    'm$pop': ary_pop,
    'm$push': ary_push_m,
    'm$rassoc': ary_rassoc,
    'm$reject': ary_reject,
    'm$reject$b': ary_reject_bang,
    'm$replace': ary_replace,
    'm$reverse': ary_reverse,
    'm$reverse$b': ary_reverse_bang,
    'm$reverse_each': ary_reverse_each,
    'm$rindex': ary_rindex,
    'm$select': ary_select,
    'm$select$b': ary_select_bang,
    'm$shift': ary_shift,
    'm$size': ary_length,
    'm$slice': ary_aref,
    'm$slice$b': ary_slice_bang,
    'm$take': ary_take,
    'm$take_while': ary_take_while,
    'm$to_a': ary_to_a,
    'm$to_ary': ary_to_a,
    'm$to_s': ary_inspect,
    'm$uniq': ary_uniq,
    'm$uniq$b': ary_uniq_bang,
    'm$unshift': ary_unshift
  });
}
