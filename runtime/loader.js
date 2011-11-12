/**
  External API to require a ruby file. This differes from internal
  require as this method takes an optional second argument that
  specifies the current working directory to use.

  If the given dir does not begin with '/' then it is assumed to be
  the name of a gem/bundle, so we actually set the cwd directory to
  the dir where that gem is stored internally (which is usually
  "/$name".

  Usage:

      opal.main("main.rb", "my_bundle");

  Previous example will set the cwd to "/my_bundle" and then try to
  load main.rb using require(). If main.rb is actually found inside
  the new cwd, it can be loaded (cwd is in the load path).

  FIXME: should we do this here?
  This will also make at_exit blocks run.

  @param {String} id the path/id to require
  @param {String} dir the working directory to change to (optional)
*/
Op.main = function(id, dir) {
  if (dir !== undefined) {
    if (dir.charAt(0) !== '/') {
      dir = '/' + dir;
    }

    FS_CWD = dir;
  }

  // set 'main' file
  Rt.gs('$0', opal.loader.find_lib(id));

  // load main file
  rb_require(id);

  // run exit blocks
  Rt.do_at_exit();
};

/**
 * Require a file by its given lib path/id, or a full path.
 *
 * If the file was required, returns true.
 *
 * @param {String} id lib path/name
 * @return {Boolean}
 */
var rb_require = function(lib) {
  var resolved = Op.loader.resolve_lib(lib);
  var cached = Op.cache[resolved];

  // If we have a cache for this require then it has already been
  // required. We return false to indicate this.
  if (cached) return false;

  Op.cache[resolved] = true;

  var source = Op.loader.get_body(resolved);
  source(rb_top_self, resolved);

  return true;
};

/**
 * Register a simple lib file. This file is simply just put into the lib
 * "directory" so it is ready to load"
 *
 * @param {String} name The lib/gem name
 * @param {String, Function} factory
 */
Op.lib = function(name, factory) {
  var name = 'lib/' + name;
  var path = '/' + name;
  Op.loader.factories[path] = factory;
  Op.loader.libs[name] = path;
};

/**
 * External api for defining a gem/bundle. This takes an object that
 * defines all the gem info and files.
 *
 * Actually register a predefined bundle. This is for the browser context
 * where bundle can be serialized into JSON and defined before hand.
 * @param {Object} info bundle info
 */
Op.bundle = function(info) {
  var factories = Op.loader.factories,
      paths     = Op.loader.paths,
      name      = info.name;

  // register all lib files
  var libs = info.libs || {};

  // register all other files
  var files = info.files || {};

  // root dir for gem is '/gem_name'
  var root_dir = '/' + name;

  var lib_dir = root_dir;

  // add lib dir to paths
  //paths.unshift(fs_expand_path(fs_join(root_dir, lib_dir)));


  for (var lib in libs) {
    if (hasOwnProperty.call(libs, lib)) {
      var file_path = lib_dir + '/' + lib;
      Op.loader.factories[file_path] = libs[lib];
      Op.loader.libs[lib] = file_path;
    }
  }

  for (var file in files) {
    if (hasOwnProperty.call(files, file)) {
      var file_path = root_dir + '/' + file;
      Op.loader.factories[file_path] = files[file];
    }
  }
}

/**
  The loader is the core machinery used for loading and executing libs
  within opal. An instance of opal will have a `.loader` property which
  is an instance of this Loader class. A Loader is responsible for
  finding, opening and reading contents of libs on disk. Within the
  browser a loader may use XHR requests or cached libs defined by JSON
  to load required libs/gems.

  @constructor
  @param {opal} opal Opal instance to use
*/
function Loader(opal) {
  this.opal = opal;
  this.paths = ['', '/lib'];
  this.factories = {};
  this.libs = {};
  return this;
}

// For minimizing
var Lp = Loader.prototype;

/**
  The paths property is an array of disk paths in which to search for
  required modules. In the browser this functionality isn't really used.

  This array is created within the constructor method for uniqueness
  between instances for correct sandboxing.
*/
Lp.paths = null;

/**
  factories of registered gems, paths => function/string. This is
  generic, but in reality only the browser uses this, and it is treated
  as the mini filesystem. Not just factories can go here, anything can!
  Images, text, json, whatever.
*/
Lp.factories = {};

/**
  Resolves the path to the lib, which can then be used to load. This
  will throw an error if the module cannot be found. If this method
  returns a successful path, then subsequent methods can assume that
  the path exists.

  @param {String} lib The lib name/path to look for
  @return {String}
*/
Lp.resolve_lib = function(lib) {
  console.log("resolving " + lib);
  var resolved = this.find_lib(lib, this.paths);

  if (!resolved) {
    rb_raise(rb_eLoadError, "no such file to load -- " + lib);
  }

  return resolved;
};

Lp.find_lib = function(id) {
  var libs = this.libs,
      lib  = 'lib/' + id;

  // try to load a lib path first - i.e. something in our load path
  if (libs[lib + '.rb']) {
    return libs[lib + '.rb'];
  }

  // next, incase our require() has a ruby extension..
  if (lib.lastIndexOf('.') === lib.length - 3) {
    if (libs[lib]) {
      return libs[lib];
    }
    // if not..
    // return null;
  }

  // if we have a .js file to require..
  if (libs[lib + '.js']) {
    return libs[lib + '.js'];
  }

  // check if id is full path..
  var factories = this.factories;

  if (factories[id]) {
    return id;
  }

  // full path without '.rb'
  if (factories[id + '.rb']) {
    return id + '.rb';
  }

  // check in current working directory.
  var in_cwd = FS_CWD + '/' + id;

  if (factories[in_cwd]) {
    return in_cwd;
  }

  return null;
};

/**
 * Returns a function body for the given path.
 */
Lp.get_body = function(path) {
  return this.factories[path];
};

/**
 *  Getter method for getting the load path for opal.
 *
 * @param {String} id The globals id being retrieved.
 * @return {Array} Load paths
 */
function rb_load_path_getter(id) {
  return Op.loader.paths;
}

/**
 * Getter method to get all loaded features.
 *
 * @param {String} id Feature global id
 * @return {Array} Loaded features
 */
function rb_loaded_feature_getter(id) {
  return loaded_features;
}

/**
 * RegExp for splitting filenames into their dirname, basename and ext.
 * This currently only supports unix style filenames as this is what is
 * used internally when running in the browser.
 */
var PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

/**
 * Holds the current cwd for the application.
 */
var FS_CWD = '/';

/**
 * Turns a glob string into a regexp
 */
function fs_glob_to_regexp(glob) {
  var parts = glob.split(''), length = parts.length, result = '';

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

