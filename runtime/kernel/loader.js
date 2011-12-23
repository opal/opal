// App entry point with require file and working dir
opal.main = function(id, dir) {
  if (dir !== undefined) {
    if (dir.charAt(0) !== '/') {
      dir = '/' + dir;
    }

    FS_CWD = dir;
  }

  opal.gvars.$0 = find_lib(id);

  try {
    top_self.m$require(null, id);

    opal.do_at_exit();
  }
  catch (e) {
    // this is defined in debug.js
    if (opal.backtrace) {
      opal.backtrace(e);
    }
  }
};

// Register simple lib
opal.lib = function(name, factory) {
  var name = 'lib/' + name,
      path = '/' + name;

  LOADER_FACTORIES[path] = factory;
  LOADER_LIBS[name]      = path;
};

// Register gem
opal.gem = function(info) {
  var loader_factories = LOADER_FACTORIES,
      loader_libs      = LOADER_LIBS,
      paths            = LOADER_PATHS,
      name             = info.name,
      libs             = info.libs || {},
      files            = info.files || {},
      root_dir         = '/' + name,
      lib_dir          = root_dir;

  // add lib dir to paths
  //paths.unshift(fs_expand_path(fs_join(root_dir, lib_dir)));

  for (var lib in libs) {
    if (hasOwnProperty.call(libs, lib)) {
      var file_path = lib_dir + '/' + lib;

      loader_factories[file_path] = libs[lib];
      loader_libs[lib]            = file_path;
    }
  }

  for (var file in files) {
    if (hasOwnProperty.call(files, file)) {
      var file_path = root_dir + '/' + file;

      loader_factories[file_path] = files[file];
    }
  }
}

LOADER_PATHS     = ['', '/lib'];
LOADER_FACTORIES = {};
LOADER_LIBS      = {};
LOADER_CACHE     = {};

var find_lib = function(id) {
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
