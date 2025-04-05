# backtick_javascript: true
# helpers: platform

class ::File < ::IO
  Separator = SEPARATOR = '/'
  ALT_SEPARATOR = `$platform.sep` != Separator ? `$platform.sep` : nil
  PATH_SEPARATOR = ':'

  module Constants
    RDONLY = 0
    WRONLY = 1
    RDWR = 2
    CREAT = 64
    EXCL = 128
    NOCTTY = 256
    TRUNC = 512
    APPEND = 1024
    NONBLOCK = 2048
    BINARY = 0
    SHARE_DELETE = 0
    NULL = `$platform.null_device`
    # Locking #
    LOCK_SH = 0x1
    LOCK_EX = 0x2
    LOCK_NB = 0x4
    LOCK_UN = 0x8
    # Globbing #
    FNM_NOESCAPE = 0x1
    FNM_PATHNAME = 0x2
    FNM_DOTMATCH = 0x4
    FNM_CASEFOLD = 0x8
    FNM_EXTGLOB = 0x10
    FNM_GLOB_NOSORT = 0x40
    FNM_GLOB_SKIPDOT = 0x80
    FNM_SYSCASE = `$platform.fs_casefold` ? 0x8 : 0x0
    FNM_SHORTNAME = 0x20 # on windows, 0 on others
    FNM_NOMATCH = 1
    FNM_ERROR = 2
  end
end
