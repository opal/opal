# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: return_val, Object, gvars, mbinc

module ::Opal
  # Create a new range instance with first and last values, and whether the
  # range excludes the last value.
  def self.range(first, last, exc)
    %x{
      var range         = new Opal.Range();
          range.begin   = first;
          range.end     = last;
          range.excl    = exc;

      return range;
    }
  end

  # top is the main object. It is a `self` in a top level of a Ruby program
  %x{
    Opal.top.$to_s = Opal.top.$inspect = $return_val('main');
    Opal.top.$define_method = top_define_method;

    // Foward calls to define_method on the top object to Object
    function top_define_method() {
      var block = top_define_method.$$p;
      top_define_method.$$p = null;
      return Opal.send($Object, 'define_method', arguments, block)
    };
  }

  # glob_brace_expand, original name ruby_brace_expand and ported from ruby/dir.c,
  # used by ::File#fnmatch and ::Dir#glob
  def self.glob_brace_expand(str, func, escape, arg)
    pi = 0
    si = 0
    nest = 0
    lbrace = nil
    rbrace = nil
    status = false

    while `str[pi]`
      if `str[pi] == '{'` && `nest++` == 0
        lbrace = pi
      elsif `str[pi] == '}'` && lbrace && `--nest` == 0
        rbrace = pi
        break
      elsif escape && `str[pi] == '\\'` && !`str[++pi]`
        break
      end
      pi = `$mbinc(str, pi)`
    end

    if lbrace && rbrace
      shift = lbrace
      pi = lbrace
      while pi < rbrace
        t = `++pi`
        nest = 0
        while pi < rbrace && !(`str[pi] == ','` && nest == 0)
          if `str[pi] == '{'`
            nest += 1
          elsif `str[pi] == '}'`
            nest -= 1
          elsif escape && `str[pi] == '\\'` && `++pi` == rbrace
            break
          end
          pi = `$mbinc(str, pi)`
        end
        buf = `str.slice(0, lbrace) + str.slice(t, pi) + str.slice(rbrace+1)`
        status = `Opal.glob_brace_expand(buf, func, escape, arg)`
        break if status
      end
    elsif !lbrace && !rbrace
      status = func.(str, arg)
    end

    status
  end

  def self.is_star_star_slash(str, idx)
    `(str[idx] === '*' && str[idx+1] === '*' && str[idx+2] === '/') ? true : false`
  end

  def self.mode_to_flags(mode)
    %x{
      const o = Opal.File.Constants;
      if (mode === nil) return nil;
      let a = mode.includes('a'),
          r = mode.includes('r'),
          w = mode.includes('w'),
          x = mode.includes('x'),
          p = mode.includes('+');
      if ( a && !r && !w &&  p &&  x) return o.APPEND | o.CREAT | o.EXCL | o.RDWR;   // ax+
      if ( a && !r && !w &&  p && !x) return o.APPEND | o.CREAT | o.RDWR;            // a+
      if ( a && !r && !w && !p &&  x) return o.APPEND | o.CREAT | o.EXCL | o.WRONLY; // ax
      if ( a && !r && !w && !p && !x) return o.APPEND | o.CREAT | o.WRONLY;          // a
      if (!a && !r &&  w &&  p &&  x) return o.RDWR   | o.CREAT | o.EXCL | o.TRUNC;  // wx+
      if (!a && !r &&  w &&  p && !x) return o.RDWR   | o.CREAT | o.TRUNC;           // w+
      if (!a && !r &&  w && !p &&  x) return o.WRONLY | o.CREAT | o.EXCL | o.TRUNC;  // wx
      if (!a && !r &&  w && !p && !x) return o.WRONLY | o.CREAT | o.TRUNC;           // w
      if (!a &&  r && !w &&  p && !x) return o.RDWR;   // r+
      if (!a &&  r && !w && !p && !x) return o.RDONLY; // r
      return nil;
    }
  end
end

::Opal
