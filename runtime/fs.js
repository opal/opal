// ..........................................................
// FILE SYSTEM
//

/**
  FileSystem namespace. Overiden in gem and node.js contexts
*/
var Fs = Op.fs = {};

/**
 RegExp for splitting filenames into their dirname, basename and ext.
 This currently only supports unix style filenames as this is what is
 used internally when running in the browser.
*/
var PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

/**
  Holds the current cwd for the application.

  @type {String}
*/
Fs.cwd = '/';

/**
  Join the given args using the default separator. The returned path
  is not expanded.

  @param {String} parts
  @return {String}
*/
function fs_join(parts) {
  parts = [].slice.call(arguments, 0);
  return parts.join('/');
}

/**
  Normalize the given path by removing '..' and '.' parts etc.

  @param {String} path Path to normalize
  @param {String} base Optional base to normalize with
  @return {String}
*/
var fs_expand_path = Fs.expand_path = function (path, base) {
  if (!base) {
    if (path.charAt(0) !== '/') {
      base = Fs.cwd;
    }
    else {
      base = '';
    }
  }

  path = fs_join(base, path);

  var parts = path.split('/'), result = [], part;

  // initial /
  if (parts[0] === '') result.push('');

  for (var i = 0, ii = parts.length; i < ii; i++) {
    part = parts[i];

    if (part == '..') {
      result.pop();
    }
    else if (part == '.' || part == '') {

    }
    else {
      result.push(part);
    }
  }

  return result.join('/');
}

/**
  Return all of the path components except the last one.

  @param {String} path
  @return {String}
*/
var fs_dirname = Fs.dirname = function(path) {
  var dirname = PATH_RE.exec(path)[1];

  if (!dirname) return '.';
  else if (dirname === '/') return dirname;
  else return dirname.substring(0, dirname.length - 1);
};

/**
  Returns the file extension of the given `file_name`.

  @param {String} file_name
  @return {String}
*/
Fs.extname = function(file_name) {
  var extname = PATH_RE.exec(file_name)[3];

  if (!extname || extname === '.') return '';
  else return extname;
};

Fs.exist_p = function(path) {
  return Op.loader.factories[fs_expand_path(path)] ? true : false;
};

/**
  Glob
*/
Fs.glob = function() {
  var globs = [].slice.call(arguments);

  var result = [], files = opal.loader.factories;

  for (var i = 0, ii = globs.length; i < ii; i++) {
    var glob = globs[i];

    var re = fs_glob_to_regexp(glob);
    // console.log("glob: " + glob);
    // console.log("re  : " + re);

    for (var file in files) {
      if (re.exec(file)) {
        result.push(file);
      }
    }
  }

  return result;
};

/**
  Turns a glob string into a regexp
*/
function fs_glob_to_regexp(glob) {
  if (typeof glob !== 'string') {
    raise(eException, "file_glob_to_regexp: glob must be a string");
  }

  // make sure absolute
  glob = fs_expand_path(glob);
  // console.log("full glob is: " + glob);
  
  var parts = glob.split(''), length = parts.length, result = '';

  var opt_group_stack = 0;

  for (var i = 0; i < length; i++) {
    var cur = parts[i];

    switch (cur) {
      case '*':
        if (parts[i + 1] == '*') {
          result += '.*';
          i++;
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

