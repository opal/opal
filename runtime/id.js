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
 * Next id to use.
 */
var ID_NEXT_ID = "a";

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
  var id = STR_TO_ID_TBL[name];

  if (!id) {
    id = VM.make_intern(name);

    STR_TO_ID_TBL[name] = id;
    ID_TO_STR_TBL[id] = name;

    ROOT_OBJECT_PROTO[id] = Qnil;
  }

  return id;
}

function rb_ivar_intern(name) {
  var id = STR_TO_ID_TBL[name];

  if (!id) {
    id = VM.make_ivar_intern(name);

    STR_TO_ID_TBL[name] = id;
    ID_TO_STR_TBL[id] = name;

    ROOT_OBJECT_PROTO[id] = Qnil;
  }

  return id;
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
    sym.$k = rb_cSymbol;
    sym.$m     = rb_cSymbol.$m_tbl;

    SYMBOL_TBL[name] = sym;
  }

  return sym;
}

/**
 * Register parse_data which gives the method_ids, ivar_ids and
 * next_id for interns etc.
 *
 *    opal.parse_data({
 *      "methods": {
 *        "foo": "aa",
 *        "bar": "ab"
 *      },
 *      "ivars": {
 *        "@bish": "ac",
 *        "@bash": "ad"
 *      },
 *      "next": "ae"
 *    });
 */
Op.parse_data = function(data) {
  // make sure we are ready to run
  ID_SET_METHOD_IDS = true;

  // method ids
  var ids = data.methods, mm_tbl = ROOT_METH_TBL_PROTO, id;

  for (var mid in ids) {
    id = ids[mid];

    STR_TO_ID_TBL[mid] = id;
    ID_TO_STR_TBL[id] = mid;

    // make sure we support method_missing for the id.
    mm_tbl[id] = rb_method_missing_caller;
  }

  // ivars
  var iv_tbl = ROOT_OBJECT_PROTO;
  ids = data.ivars;

  for (var iv in ids) {
    id = ids[iv];

    STR_TO_ID_TBL[iv] = id;
    ID_TO_STR_TBL[id] = iv;

    // make sure we set all ivars to nil on root object tbl
    iv_tbl[id] = Qnil;
  }

  // next ID
  ID_NEXT_ID = data.next;
};
