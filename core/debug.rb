#############################################################
# DEBUG - only included in debug mode
#

class Exception
  def backtrace
    %x{
      var result = [],
          stack  = this.opal_stack || [],
          frame,
          recv,
          meth;

      for (var i = stack.length - 1; i >= 0; i--) {
        frame = stack[i];
        meth  = frame.meth;
        recv  = frame.recv;
        klass = meth.$debugKlass;

        if (recv.o$flags & T_OBJECT) {
          recv = class_real(recv.o$klass);
          recv = (recv === klass ? recv.o$name : klass.o$name + '(' + recv.o$name + ')') + '#';
        }
        else {

          recv = recv.o$name + '.';
        }

        result.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + meth.$debugFile + ':' + meth.$debugLine);
      }

      return result;
    }
  end
end
