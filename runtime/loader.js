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
  Rt.gs('$0', rb_find_lib(id));

  // load main file
  rb_top_self.$m.require(rb_top_self, id);

  // run exit blocks
  Rt.do_at_exit();
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
  LOADER_FACTORIES[path] = factory;
  LOADER_LIBS[name] = path;
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
  var loader_factories = LOADER_FACTORIES,
      loader_libs      = LOADER_LIBS,
      paths     = LOADER_PATHS,
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
      loader_factories[file_path] = libs[lib];
      loader_libs[lib] = file_path;
    }
  }

  for (var file in files) {
    if (hasOwnProperty.call(files, file)) {
      var file_path = root_dir + '/' + file;
      loader_factories[file_path] = files[file];
    }
  }
}

LOADER_PATHS = ['', '/lib'];

LOADER_FACTORIES = {};

LOADER_LIBS = {};

LOADER_CACHE = {};

var rb_find_lib = function(id) {
  var libs = LOADER_LIBS,
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
  var factories = LOADER_FACTORIES;

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

