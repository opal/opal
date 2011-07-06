
/**
  Valid file extensions opal can load/run
*/
var load_extensions = {};

load_extensions['.js'] = function(loader, path) {
  var source = loader.file_contents(path);
  return load_execute_file(loader, source, path);
};

load_extensions['.rb'] = function(loader, path) {
  var source = loader.ruby_file_contents(path);
  return load_execute_file(loader, source, path);
};

/**
  Require a file by its given lib path/id, or a full path.

  @param {String} id lib path/name
  @return {Boolean}
*/
var load_require = Op.require = Rt.require = function(lib) {
  var resolved = Op.loader.resolve_lib(lib);
  var cached = Op.cache[resolved];

  // If we have a cache for this require then it has already been
  // required. We return false to indicate this.
  if (cached) return false;

  Op.cache[resolved] = true;

  // try/catch wrap entire file load?
  load_file(Op.loader, resolved);

  return true;
};

/**
  Sets the primary 'gem', by name, so we know which cwd to use etc.
  This can be changed at anytime, but it is only really recomended
  before the application is run.

  Also, if a gem with the given name cannot be found, then an error
  will/should be thrown.

  @param {String} name The root gem name to use
*/
Op.primary = function(name) {
  Fs.cwd = '/' + name;
};

/**
  Just go ahead and run the given block of code. The passed function
  should rake the usual runtime, self and file variables which it will
  be passed.

  @param {Function} body
*/
Op.run = function(body) {
  var res = Qnil;

  if (typeof body != 'function') {
    throw new Error("Expected body to be a function");
  }

  try {
    res = body(Rt, Rt.top, "(opal)");
  }
  catch (err) {
    console.log("catching error");
    var exc, stack;
    exc = err.$rb_exc;

    if (exc && exc['@message']) {
      console.log(exc.$klass.__classid__ + ': ' + exc['@message']);
    }
    else {
      console.log('NativeError: ' + err.message);
    }

    // first try (if in debug mode...)
    if (Db.backtrace()) {
      console.log(Db.backtrace());
      Db.stack = [];
    }
    else if (stack = err.stack) {
      console.log(stack);
    }
  }
  return res;
};

/**
  Register a lib or gem with the given info. If info is an object then
  a gem will be registered with the object represented a JSON version
  of the gemspec for the gem. If the info is simply a function (or
  string?) then a singular lib will be registerd with the function as
  its body.

  @param {String} name The lib/gem name
  @param {Object, Function} info
*/
Op.register = function(name, info) {
  // make sure name is useful
  if (typeof name !== 'string') {
    throw new Error("Cannot register a lib without a proper name");
  }

  // registering a lib/file?
  if (typeof info === 'string' || typeof info === 'function') {
    load_register_lib(name, info);
  }
  // registering a gem?
  else if (typeof info === 'object') {
    load_register_gem(name, info);
  }
  // something has gone wrong..
  else {
    throw new Error("Invalid gem/lib data for '" + name + "'");
  }
};

/**
  Actually register a predefined gem. This is for the browser context
  where gems can be serialized into JSON and defined before hand.

  @param {String} name Gem name
  @param {Object} info Serialized gemspec
*/
function load_register_gem(name, info) {
  var factories = Op.loader.factories,
      paths     = Op.loader.paths;

  // register all lib files
  var files = info.files || {};

  // root dir for gem is '/gem_name'
  var root_dir = '/' + name;

  // for now assume './lib' as dir for all libs (should be dynamic..)
  var lib_dir = './lib';

  // add lib dir to paths
  paths.unshift(fs_expand_path(fs_join(root_dir, lib_dir)));

  for (var file in files) {
    if (files.hasOwnProperty(file)) {
      var file_path = fs_expand_path(fs_join(root_dir, file));
      factories[file_path] = files[file];
    }
  }

  // register other info? (version etc??)
}

/**
  Register a single lib/file in browser before its needed. These libs
  are added to top level dir '/lib_name.rb'

  @param {String} name Lib name
  @param {Function, String} factory
*/
function load_register_lib(name, factory) {
  var path = '/' + name;
  Op.loader.factories[path] = factory;
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
  factories of registered packages, paths => function/string. This is
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
  var resolved = this.find_lib(lib, this.paths);

  if (!resolved) {
    throw new Error("LoadError: no such file to load -- " + lib);
  }

  return resolved;
};

/**
  Locates the lib/file using the given paths.

  @param {String} lib The lib path/file to look for
  @param {Array} paths Load paths to use
  @return {String} Located path
*/
Lp.find_lib = function(id, paths) {
  var extensions = this.valid_extensions, factories = this.factories, candidate;

  for (var i = 0, ii = extensions.length; i < ii; i++) {
    for (var j = 0, jj = paths.length; j < jj; j++) {
      candidate = fs_join(paths[j], id + extensions[i]);

      if (factories[candidate]) {
        return candidate;
      }
    }
  }

  // try full path (we try to load absolute path!)
  if (factories[id]) {
    return id;
  }

  // try full path with each extension
  for (var i = 0; i < extensions.length; i++) {
    candidate = id + extensions[i];
    if (factories[candidate]) {
      return candidate;
    }
  }

  // try each path with no extension (if id already has extension)
  for (var i = 0; i < paths.length; i++) {
    candidate = fs_join(paths[j], id);

    if (factories[candidate]) {
      return candidate;
    }
  }

  return null;
};

/**
  Valid factory format for use in require();
*/
Lp.valid_extensions = ['.js', '.rb'];

/**
  Get lib contents for js files
*/
Lp.file_contents = function(path) {
  return this.factories[path];
};

Lp.ruby_file_contents = function(path) {
  return this.factories[path];
};

/**
  Actually run file with resolved name.

  @param {Loader} loader
  @param {String} path
*/
function load_file(loader, path) {
  var ext = load_extensions[PATH_RE.exec(path)[3] || '.js'];

  if (!ext) {
    throw new Error("load_run_file - Bad extension for resolved path");
  }

  ext(loader, path);
}

/**
  Run content which must now be javascript. Arguments we pass to func
  are:

    $rb
    top_self
    filename

  @param {String, Function} content
  @param {String} path
*/
function load_execute_file(loader, content, path) {
  var args = [Rt, top_self, path];

  if (typeof content === 'function') {
    return content.apply(Op, args);

  } else if (typeof content === 'string') {
    var func = loader.wrap(content, path);
    return func.apply(Op, args);

  } else {
    throw new Error(
      "Loader.execute - bad content sent for '" + path + "'");
  }
}

/**
  Getter method for getting the load path for opal.

  @param {String} id The globals id being retrieved.
  @return {Array} Load paths
*/
function load_path_getter(id) {
  return Rt.A(opal.loader.paths);
}

/**
  Getter method to get all loaded features.

  @param {String} id Feature global id
  @return {Array} Loaded features
*/
function loaded_feature_getter(id) {
  return loaded_features;
}

function obj_require(obj, path) {
  return Rt.require(path) ? Qtrue : Qfalse;
}

