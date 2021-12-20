module ::Errno
  errors = [
    [:EINVAL, 'Invalid argument', 22],
    [:EEXIST, 'File exists', 17],
    [:EISDIR, 'Is a directory', 21],
    [:EMFILE, 'Too many open files', 24],
    [:EACCES, 'Permission denied', 13],
    [:EPERM, 'Operation not permitted', 1],
    [:ENOENT, 'No such file or directory', 2]
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
