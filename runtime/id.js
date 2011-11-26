function mid_to_jsid(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
}

function rb_method_missing_caller(recv, id) {
  var proto = recv == null ? NilClassProto : recv;
  var meth = mid_to_jsid[id];
  var func = proto.$m[mid_to_jsid('method_missing')];
  var args = [recv, 'method_missing', meth].concat(ArraySlice.call(arguments, 2));
  return func.apply(null, args);
}

rb_method_missing_caller.$method_missing = true;

