opal.main = function(id) {
  opal.gvars.$0 = find_lib(id);

  try {
    top_self.$require(null, id);

    opal.do_at_exit();
  }
  catch (e) {
    // this is defined in debug.js
    console.log(e.$klass.$name + ': ' + e.message);
    console.log("\t" + e.$backtrace().join("\n\t"));
  }
};

/**
 * Register a standard file. This can be used to register non-lib files.
 * For example, specs can be registered here so they are available.
 *
 * NOTE: Files should be registered as a full path with given factory.
 *
 * Usage:
 *
 *    opal.file('/spec/foo.rb': function() {
 *      // ...
 *    });
 */
opal.file = function(file, factory) {
  FACTORIES[file] = factory;
};

/**
 * Register a lib.
 *
 * Usage:
 *
 *    opal.lib('my_lib', function() {
 *      // ...
 *    });
 *
 *    opal.lib('my_lib/foo', function() {
 *      // ...
 *    });
 */
opal.lib = function(lib, factory) {
  var file        = '/lib/' + lib + '.rb';
  FACTORIES[file] = factory;
  LIBS[lib]       = file;
};

FACTORIES = {};
LIBS      = {};
LOADER_PATHS     = ['', '/lib'];
LOADER_CACHE     = {};

function find_lib(id) {
  var lib  = '/lib/' + id;

  // try to load a lib path first - i.e. something in our load path
  if (FACTORIES[lib + '.rb']) {
    return lib + '.rb';
  }

  // next, incase our require() has a ruby extension..
  if (FACTORIES[lib]) {
    return lib;
  }

  // check if id is full path..
  if (FACTORIES[id]) {
    return id;
  }

  // full path without '.rb'
  if (FACTORIES[id + '.rb']) {
    return id + '.rb';
  }

  // check in current working directory.
  var in_cwd = FS_CWD + '/' + id;

  if (FACTORIES[in_cwd]) {
    return in_cwd;
  }
};

// Split to dirname, basename and extname
var PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

// Current working directory
var FS_CWD = '/';

// Turns a glob string into a regexp
function fs_glob_to_regexp(glob) {
  var parts  = glob.split(''),
      length = parts.length,
      result = '';

  var opt_group_stack = 0;

  for (var i = 0; i < length; i++) {
    var cur = parts[i];

    switch (cur) {
      case '*':
        if (parts[i + 1] === '*' && parts[i + 2] === '/') {
          result += '.*';
          i += 2;
        }
        else {
          result += '[^/]*';
        }
        break;

      case '.':
        result += '\\';
        result += cur;
        break;

      case ',':
        if (opt_group_stack) {
          result += '|';
        }
        else {
          result += ',';
        }
        break;

      case '{':
        result += '(';
        opt_group_stack++;
        break;

      case '}':
        if (opt_group_stack) {
          result += ')';
          opt_group_stack--;
        }
        else {
          result += '}'
        }
        break;

      default:
        result += cur;
    }
  }

  return new RegExp('^' + result + '$');
};
