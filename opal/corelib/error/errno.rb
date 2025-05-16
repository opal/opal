# backtick_javascript: true
# use_strict: true

module ::Errno
  errors = [
    [:EPERM, 'Operation not permitted', 1],
    [:ENOENT, 'No such file or directory', 2],
    [:ESRCH, 'No such process', 3],
    [:ENXIO, 'No such device or address', 6],
    [:EBADF, 'Bad file descriptor', 9],
    [:ECHILD, 'No child processes', 10],
    [:EACCES, 'Permission denied', 13],
    [:EBUSY, 'resource busy or locked', 16],
    [:EEXIST, 'File exists', 17],
    [:ENOTDIR, 'Not a directory', 20],
    [:EISDIR, 'Is a directory', 21],
    [:EINVAL, 'Invalid argument', 22],
    [:EMFILE, 'Too many open files', 24],
    [:ESPIPE, 'Illegal seek', 29],
    [:EPIPE, 'Broken pipe', 32],
    [:ENAMETOOLONG, 'File name too long', 36],
    [:ENOTEMPTY, 'Directory not empty', 39],
    [:ELOOP, 'Too many symbolic links encountered', 40],
    [:EILSEQ, 'Illegal byte sequence', 84],
    [:EOPNOTSUPP, 'Operation not supported on transport endpoint', 95]
  ]

  klass = nil

  %x{
    var i;
    for (i = 0; i < errors.length; i++) {
      (function() { // Create a closure
        var class_name = errors[i][0];
        var default_message = errors[i][1];
        var errno = errors[i][2];

        klass = Opal.klass(self, Opal.SystemCallError, class_name);
        klass.errno = errno;

        #{
          class << klass
            def new(name = nil)
              message = `default_message`
              message += " - #{name}" if name
              super(message)
            end
          end
        }
      })();
    }
  }
end

class ::SystemCallError < ::StandardError
  def errno
    self.class.errno
  end

  class << self
    attr_reader :errno
  end
end
