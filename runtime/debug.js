/**
 * Debug Mode
 * ==========
 *
 * This file contains all methods/functions used in debug mode. Most
 * methods can also be used directly outside debug mode as well.
 */
var DEBUG_MODE = false;

/**
 *
 */
var rb_debug_funcall = function(recv, id) {
  // Sending to null/undefined is a straight up error
  if (recv == null) {
    rb_raise(rb_eNoMethodError, "Cannot send methods to null/undefined");
  }

  // Sending a method that doesnt exist (toll free recv or non ruby obj)
  if (!recv[id]) {
    rb_raise(rb_eNoMethodError, "Cannot send method to receiver");
  }

  // Otherwise, all is good - send away.
  return recv[id].apply(recv, ArraySlice.call(arguments, 2));
};

var rb_debug_blockcall(recv, id, block) {
};

