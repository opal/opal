# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: mbinc, platform

module ::Opal
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

  def self.is_dirsep(chr)
    `chr == '/' || (!!$platform.windows && chr == '\\')`
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

  # methods for File.expand_path and File.absolute_path
  # straightforward port of rb_file_expand_path_internal from ruby/file.c, more or less
  # just like in ruby/file.c
  def self.append_fspath(result, dir)
    [result + dir, `dir.length`]
  end

  # just like in ruby/file.c
  def self.bufcopy(fname, srcptr, srclen, result, pi)
    skip = 1 # skippathsep(pi) only matters on Apple
    pi += skip
    result += `fname.slice(srcptr, srcptr + srclen)`
    pi += srclen
    [result, pi]
  end

  # just like in ruby/file.c
  def self.bufinit(result)
    [0, `result.length`, 0, `result.length`]
  end

  # just like in ruby/file.c
  def self.chompdirsep(pth, idx)
    while `pth[idx]`
      if is_dirsep(`pth[idx]`)
        idx += 1
        last = idx
        while `pth[idx]` && is_dirsep(`pth[idx]`)
          idx += 1
        end
        return last if `!pth[idx]`
      else
        idx = `$mbinc(pth, idx)`
      end
    end
    idx
  end

  # just like in ruby/file.c, yet, there is no guarantee that it works
  # like intended with the various JS engines
  def self.getcwdofdrv(drv)
    drive = drv + ':'
    ::Dir.chdir(drive) do
      # the only way that I know to get the current directory
      # of a particular drive is to change chdir() to that drive
      ::Dir.pwd
    end
  rescue
    drive
  end

  # just like in ruby/file.c
  def self.has_drive_letter(pd)
    pd.match?(/^[[:alpha:]]:/)
  end

  # just like in ruby/file.c
  def self.istrailinggarbage(x)
    `x == '.' || x == ' '`
  end

  # just like in ruby/file.c
  def self.not_same_drive(pd, drive)
    return false if `pd.length < 2`
    if has_drive_letter(pd)
      pd[0] != drive
    else
      is_dirsep(`pd[0]`) && is_dirsep(`pd[1]`)
    end
  end

  # just like in ruby/file.c
  def self.rb_enc_path_next(pth, idx)
    while `pth[idx]` && !is_dirsep(`pth[idx]`)
      idx = `$mbinc(pth, idx)`
    end
    idx
  end

  # rb_enc_path_skip_prefix, just like in ruby/file.c
  def self.skipprefix(pth, idx)
    if `$platform.windows`
      if `pth[idx + 1]` && is_dirsep(`pth[idx]`) && is_dirsep(`pth[idx + 1]`)
        idx += 2
        while `pth[idx]` && is_dirsep(`pth[idx]`)
          idx += 1
        end
        idx = rb_enc_path_next(pth, idx)
        if `pth[idx]` && `pth[idx + 1]` && !is_dirsep(`pth[idx + 1]`)
          idx = rb_enc_path_next(pth, idx + 1)
        end
        return idx
      end
      return idx + 2 if has_drive_letter(`idx > 0 ? pth.slice(idx) : pth`)
    end
    idx
  end

  # just like in ruby/file.c
  def self.skiproot(pth, d)
    idx = 0
    if `$platform.windows` && 2 < d && has_drive_letter(pth)
      idx += 2
    end
    while idx < d && is_dirsep(`pth[idx]`)
      idx += 1
    end
    idx
  end

  # rb_enc_path_last_separator, just like in ruby/file.c
  def self.strrdirsep(pth, d)
    last = nil
    idx = 0
    while idx < d
      if is_dirsep(`pth[idx]`)
        tmp = idx
        idx += 1
        while idx < d && is_dirsep(`pth[idx]`)
          idx += 1
        end
        break if idx >= d
        last = tmp
      else
        idx = `$mbinc(pth, idx)`
      end
    end
    last
  end

  # the label 'endpath' split into 2 stages
  def self.endpath_stage1(fname, b, s, result, pi)
    bufcopy(fname, b, s - b, result, pi)
  end

  def self.endpath_stage2(result, pi, buf, enc)
    pi += 1 if pi == skiproot(result, pi + `(result[pi] ? 1 : 0)`) - 1
    # if `$platform.windows`
    # end
    result = `result.slice(0, pi - buf)`
    `Opal.str(result, enc)`
  end

  # just like in ruby/file.c
  def self.rb_file_expand_path_internal(fname, dname, abs_mode, long_name, result)
    enc = fname.encoding
    user = nil
    b = nil

    fend = `fname.length`
    s = 0

    buf, buflen, pi, pend = bufinit(result)

    if !abs_mode && `fname[s] == '~'`
      if is_dirsep(`fname[1]`) || `!fname[1]`
        buf = 0
        b = 0
        s += 1
        s += 1 if `fname[s]`
        result += ::Dir.home # rb_default_home_dir
      else
        b = s
        while `fname[s]` && !is_dirsep(`fname[s]`) # nextdirsep
          s += 1
        end
        b += 1
        userlen = s - b
        user = `fname.slice(b, s)`
        result += ::Dir.home(user)
        buf = pi + 1
        pi += userlen
      end
      unless ::File.absolute_path?(result)
        raise(::ArgumentError, "non-absolute home of #{user}") if user
        raise(::ArgumentError, 'non-absolute home')
      end
      buf, buflen, pi, pend = bufinit(result)
      pi = pend
    elsif `$platform.windows` && has_drive_letter(fname)
      if is_dirsep(`fname[2]`)
        # specified drive letter, and full path
        # skip drive letter
        pi += 2
        s += 2
        result += `fname.slice(0,2)`
      else
        # specified drive, but not full path
        same = false

        if dname && not_same_drive(dname, fname[0])
          result = rb_file_expand_path_internal(dname, nil, abs_mode, long_name, result)
          same = true if has_drive_letter(fname) && result[0].downcase == fname[0].downcase
        end
        if !same
          result += getcwdofdrv(fname[0])
        else
          # leave result unchanged
        end
        pi = chompdirsep(result, skiproot(result, pi))
        s += 2
      end
    elsif !(::File.absolute_path?(fname) || (`$platform.windows` && is_dirsep(`fname[0]`)))
      if dname
        result = rb_file_expand_path_internal(dname, nil, abs_mode, long_name, result)
        buf, buflen, pi, pend = bufinit(result)
        pi = pend
      else
        result, e = append_fspath(result, ::Dir.pwd)
        buf, buflen, pi, pend = bufinit(result)
        pi = e
      end
      if `$platform.windows` && is_dirsep(`fname[s]`)
        pi = skipprefix(result, pi)
      else
        pi = chompdirsep(skiproot(result, pi), pi)
      end
    else
      b = s
      s += 1
      while is_dirsep(`fname[s]`)
        s += 1
      end
      len = s - b
      pi = buf + len
      result += '/' * len
    end
    if pi > buf && `result[pi - 1] == '/'`
      pi -= 1
    else
      result += '/'
    end
    root = skipprefix(result, pi + 1)
    b = s
    while `fname[s]`
      case `fname[s]`
      when '.'
        s1 = s
        s += 1
        if b == s1
          # beginning of path element
          case `(fname[s] || '')`
          when ''
            b = s
          when '.'
            if `!fname[s + 1]` || is_dirsep(`fname[s + 1]`)
              # We must go back to the parent
              n = strrdirsep(result, pi)
              result = `result.slice(0, pi)`
              if n.nil?
                result += '/'
              else
                result = `result.slice(0, n + 1)`
                pi = n
              end
              s += 1
              b = s
            elsif `$platform.windows`
              s += 1
              while istrailinggarbage(`fname[s]`)
                s += 1
              end
            end
          when '/'
            s += 1
            b = s
          when '\\'
            if `$platform.windows`
              s += 1
              b = s
            else
              s += 1
            end
          end
        end
      when ' '
        if `$platform.windows`
          e = s
          while istrailinggarbage(`fname[s]`)
            s += 1
          end
          if `!fname[s]`
            s = e
            result, pi = endpath_stage1(fname, b, s, result, pi)
            return endpath_stage2(result, pi, buf, enc)
          end
        else
          s += 1
        end
      when '/'
        if s > b
          result, pi = bufcopy(fname, b, s - b, result, pi)
          result += '/'
        end
        s += 1
        b = s
      when '\\'
        if `$platform.windows`
          if s > b
            result, pi = bufcopy(fname, b, s - b, result, pi)
            result += '/'
          end
          s += 1
          b = s
        else
          s += 1
        end
      else
        s = `$mbinc(fname, s)`
      end
    end

    if s > b
      result, pi = endpath_stage1(fname, b, s, result, pi)
    end
    endpath_stage2(result, pi, buf, enc)
  end
end

::Opal
