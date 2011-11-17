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

opal.ID_TO_STR_TBL = ID_TO_STR_TBL;

/**
 * Next id to use.
 */
var ID_NEXT_ID = "$a";

/**
 * yielder count for making next id. Dealing with strings and next char
 * etc is very slow, so we just use the next_id (in the browser) and
 * just append a numeric value to it. this is much faster.
 */
var ID_NEXT_ID_YIELD = 0;

VM.make_intern = function(name) {
  var intern = ID_NEXT_ID + (ID_NEXT_ID_YIELD++);
  return intern;
};

VM.make_ivar_intern = function(name) {
  var intern = ID_NEXT_ID + (ID_NEXT_ID_YIELD++);
  return intern;
};

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

    //ROOT_OBJECT_PROTO[id] = Qnil;
  }

  return id;
}

function rb_ivar_intern(name) {
  var id = STR_TO_ID_TBL[name];

  if (!id) {
    id = VM.make_ivar_intern(name);

    STR_TO_ID_TBL[name] = id;
    ID_TO_STR_TBL[id] = name;

    //ROOT_OBJECT_PROTO[id] = Qnil;
  }

  return id;
}

/**
 * Register parse_data which gives the method_ids, ivar_ids and
 * next_id for interns etc.
 *
 *    opal.parse_data({
 *      "methods": {
 *        "foo": "$aa",
 *        "bar": "$ab"
 *      },
 *      "ivars": {
 *        "@bish": "$ac",
 *        "@bash": "$ad"
 *      },
 *      "next": "$ae"
 *    });
 */
Op.parse_data = function(data) {
  // make sure we are ready to run
  ID_SET_METHOD_IDS = true;

  // method ids
  var ids = data.methods, id;

  for (var mid in ids) {
    id = ids[mid];

    STR_TO_ID_TBL[mid] = id;
    ID_TO_STR_TBL[id] = mid;

    // make sure we support method_missing for the id.
    rb_make_method_missing_stub(id, mid);
  }

  // ivars
  ids = data.ivars;

  for (var iv in ids) {
    id = ids[iv];

    STR_TO_ID_TBL[iv] = id;
    ID_TO_STR_TBL[id] = iv;
  }

  // next ID
  ID_NEXT_ID = data.next;
};

function rb_make_method_missing_stub(id, mid) {
  var meth = function(self) {
    var proto = self == null ? NilClassProto : self;
    var mmfn = proto.$m[STR_TO_ID_TBL['method_missing']];
    var args = [self, mid].concat(ArraySlice.call(arguments, 1));
    return mmfn.apply(null, args);
  };

  meth.$method_missing = true;

  return base_method_table[id] = meth;
}
