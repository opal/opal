# Instances of {Exception} and its subclasses are used to hold error
# information between `raise` calls, `begin` blocks and `rescue` statements.
# `Exceptions` will hold an optional `message`, which is a description
# of the error that occured. The exception `type` is also useful, and is
# just the name of the class that is a decendant of `Exception`.
# Subclasses are generally made of `StandardError`, but a subclass of
# any core `Exception` class is valid.
#
# Implementation details
# ----------------------
#
# Inside opal, exceptions are instances of the native javascript `Error`
# objects. This allows an efficient means to "piggy-back" the javascript
# try/catch/finally statements, as well as the `throw` statement for
# actually raising exceptions.
#
# Subclasses of `Exception` can also be used on top of `Error`, and the
# correct class and method tables for these subclasses are set in
# {.allocate}.
#
# Exceptions cannot be altered once created, so their message is
# permanently fixed. To improve debugging opal, once an exception it
# {#initialize}, the native error has its `.message` property set to a
# descriptive name with the format `ErrorClassName: error_message`. This
# helps to observe top level error statements appearing in debug tools.
# The original error message may be received using the standard
# {#message} or {#to_s} methods.
#
# Accessing the `backtrace` of an exception is platform dependant. It is
# fully supported on the server side v8 context, but differs in the
# browser context as some browsers have better support than others. The
# backtrace should not be relied on, and is supported purely on a
# platform to platform basis.
class Exception

  # We also need to set err.$m to the right method table incase a subclass adds
  # custom methods.. just get this from the klass: self.
  def self.allocate
    `var err = new Error();
    err.$klass = self;
    err.$m = self.$m_tbl;
    return err;`
  end

  def initialize(message = '')
    @message = message
    `return self.message = self.$klass.__classid__ + ': ' + message;`
  end

  def message
    @message || `self.message`
  end

  def inspect
    `return "#<" + self.$klass.__classid__ + ": '" + #{@message} + "'>";`
  end

  def to_s
    @message
  end
end

class StandardError < Exception; end
class RuntimeError < Exception; end
class LocalJumpError < StandardError; end
class TypeError < StandardError; end

class NameError < StandardError; end
class NoMethodError < NameError; end
class ArgumentError < StandardError; end

class ScriptError < Exception; end
class LoadError < ScriptError; end

class IndexError < StandardError; end
class KeyError < IndexError; end
class RangeError < StandardError; end

