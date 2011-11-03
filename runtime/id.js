/**
 * Simple var to indicate whether corelib/libs have registered their
 * method_ids. If opal tries to init and this is false, then we know
 * something has probably gone wrong.
 */
var ID_SET_METHOD_IDS = false;

/**
 * Javascript object of all string names to their id values.
 */
var STR_TO_ID_TBL = {};

/**
 * Javascript object of all ids back to their normal string names.
 */
var ID_TO_STR_TBL = {};

/**
 * String name => id.
 *
 * This method returns the internal id for the given name, which may
 * be a method_id, or ivar name etc. If one does not exist, then one
 * will be created. In the browser, this is simple, to keep things
 * fast. In ruby context, this will use the parser to generate a new
 * id inside the Parser instance.
 */
function rb_intern(name) {
  return STR_TO_ID_TBL[name];
}

/**
 * All symbols. String name => Symbol.
 */
var SYMBOL_TBL = {};

/**
 * Symbol creation. Creates a symbol from the given str name.
 *
 * FIXME: this should, in future, use id instead of string.
 */
function rb_symbol(name) {
  var sym = SYMBOL_TBL[name];

  if (!sym) {
    sym = new String(name);
    sym.$klass = rb_cSymbol;
    sym.$m     = rb_cSymbol.$m_tbl;

    SYMBOL_TBL[name] = sym;
  }

  return sym;
}

/**
 * Register the given set of method names to their internal ids. This
 * is passed from the compiler for the intial app launch, as well as
 * between each individual compile (on the command line). The object
 * is the format { "method_name": "id" }.
 */
Op.method_ids = function(ids) {
  // make sure we are ready to run
  ID_SET_METHOD_IDS = true;

  var id, mm_tbl = rb_cBasicObject.$m_tbl;

  for (var mid in ids) {
    id = ids[mid];
    console.log("registering " + mid + " for " + id);

    STR_TO_ID_TBL[mid] = id;
    ID_TO_STR_TBL[id] = mid;

    // make sure we support method missing for the id.
    mm_tbl[id] = rb_method_missing_caller;
  }
};
