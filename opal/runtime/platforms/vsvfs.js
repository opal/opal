// Very Simple Virtual File System
// Directories are represented by Map
// Files are represented by Uint8Array, u8a function arg below must be a Uint8Array
// Separator is '/'
// No permissions, links, ownership or other fancy things.

// Class FileStat, as used by Node and Opal
Opal.VSVFS_FileStat = class {
  constructor(obj) { this.obj = obj; }
  get atimeMs() { return 0; }
  get birthtimeMs() { return 0; }
  get blksize() { return 1024; }
  get blocks() { return Math.ceil(this.obj.byteLength / 1024); }
  get ctimeMs() { return 0; }
  get dev() { }
  get gid() { return -1; }
  get ino() { }
  get mode() { return 0; }
  get mtimeMs() { return 0; }
  get nlink() { return 0; }
  get rdev() { }
  get size() { return this.obj.byteLength; }
  get uid() { return -1; }
  isBlockDevice() { return false; }
  isCharacterDevice() { return false; }
  isDirectory() { return this.obj instanceof Map; }
  isFile() { return this.obj instanceof Uint8Array; }
  isFIFO() { return false; }
  isSocket() { return false; }
  isSymbolicLink() { return false; }
}

Opal.VSVFS = class {
  // Using a Map for the FS
  constructor() { this.fs = new Map(); this.wd = '/'; }

  // helper to ensure absolute paths
  absolute(path) {
    if (path === '.') return this.wd;
    if (path === '..') {
      let parts = this.wd.split('/');
      parts.pop();
      path = parts.join('/');
      if (path === '') return '/';
      return path;
    }
    if (path[0] !== '/') path = this.wd + '/' + path;
    return path.replaceAll(/\/+/g, '/');
  }

  // helper to find working directory and entry from path
  wd_name_entry(path) {
    let directories, wd = this.fs, name, i, p;
    path = this.absolute(path);
    if (path === '/') return [this.fs, '/', this.fs];
    directories = path.split('/');
    name = directories.pop();
    while (name == '') name = directories.pop();
    if (!name) throw new Error("ENOENT");
    for (i = 0; i < directories.length; i++) {
      p = directories[i];
      if (p === '') continue;
      wd = wd.get(p);
      if (!wd) throw new Error("ENOENT");
      if (!(wd instanceof Map)) throw new Error("ENOTDIR");
    }
    return [wd, name, wd.get(name)];
  }

  // Directories

  // Change current working directory
  chdir(path) {
    let wd, name, entry;
    path = this.absolute(path);
    [wd, name, entry] = this.wd_name_entry(path);
    if (!entry) throw new Error("ENOENT");
    if (!(entry instanceof Map)) throw new Error("ENOTDIR");
    path = path.replace(/\/+$/, '');
    if (path === '') path = '/';
    return this.wd = path;
  }

  // Current working directory
  cwd() { return this.wd; }

  // Create a directory
  mkdir(path) {
    let wd, entry, name;
    [wd, name, entry] = this.wd_name_entry(path);
    if (entry instanceof Uint8Array) throw new Error("EEXIST");
    if (!entry) wd.set(name, new Map());
  }

  // Delete directory
  rmdir(path) {
    let wd, entry, name;
    [wd, name, entry] = this.wd_name_entry(path);
    if (name === '/') return;
    if (entry) {
      if (!(entry instanceof Map)) throw new Error("ENOTDIR");
      if (entry.size > 0) throw new Error("ENOTEMPTY");
      wd.delete(name);
    }
  }

  // List directory entries
  ls(path) {
    let wd, entry, name;
    [wd, name, entry] = this.wd_name_entry(path);
    if (entry instanceof Map) return Array.from(entry.keys());
    return [name];
  }

  // Files

  // Read from file, read data is copied into u8a target buffer
  read(path, u8a, pos, len) {
    let wd, entry, name;
    [wd, name, entry] = this.wd_name_entry(path);
    if (!entry) throw new Error("ENOENT");
    if (entry instanceof Map) throw new Error("EISDIR");
    entry = entry.slice(pos, Math.min(pos + len, u8a.byteLength));
    u8a.set(entry);
    return entry.byteLength;
  }

  // Delete file
  rm(path) {
    let wd, entry, name;
    [wd, name, entry] = this.wd_name_entry(path);
    if (entry) {
      if (entry instanceof Map) throw new Error("EISDIR");
      wd.delete(name);
    }
  }

  // Stat a file
  stat(path) {
    let wd, entry, name;
    [wd, name, entry] = this.wd_name_entry(path);
    if (!entry) throw new Error("ENOENT");
    return new Opal.VSVFS_FileStat(entry);
  }

  // truncate a file to len
  truncate(path, len) {
    let wd, entry, name;
    [wd, name, entry] = this.wd_name_entry(path);
    if (!entry) throw new Error("ENOENT");
    if (entry instanceof Map) throw new Error("EISDIR");
    entry = entry.slice(0, len);
    wd.set(name, entry);
  }

  // Create or write file, data to be written is copied from u8a source buffer
  write(path, u8a, pos, len) {
    let wd, entry, name, new_entry;
    [wd, name, entry] = this.wd_name_entry(path);
    if (entry instanceof Map) throw new Error("EISDIR");
    if (u8a.byteLength > len) u8a = u8a.slice(0, len);
    if (entry) {
      if ((pos + len) > entry.byteLength) {
        new_entry = new Uint8Array(pos + len);
        new_entry.set(entry);
      } else new_entry = entry;
    } else new_entry = new Uint8Array(pos + len);

    new_entry.set(u8a, pos);
    wd.set(name, new_entry);
    return len;
  }
}
