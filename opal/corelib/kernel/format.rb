# helpers: coerce_to
# backtick_javascript: true

module ::Kernel
  def format(format_string, *args)
    # Returns the string resulting from formatting args into format_string.

    # this is a more or less traightforward port of rb_str_format from ruby/sprintf.c

    #if args.length == 1 && (args[0].respond_to?(:to_ary) rescue nil) # guard BasicObjects not having #respond_to?
    #  ary = ::Opal.coerce_to?(args[0], ::Array, :to_ary)
    #  args = ary.to_a unless ary.nil?
    #end

    format_string = ::Opal.coerce_to!(format_string, ::String, :to_str)
    # rb_must_asciicompat(format_string)
    enc = format_string.encoding
    orig = format_string
    # format_string = format_string.dup.freeze
    pi = -1 # p = RSTRING_PTR(format_string)
    pe = `format_string.length` # pe = pi + RSTRING_LEN(format_string)
    result = ''

    # some local constants
    fnoneC = 0
    fsharpC = 1
    fminusC = 2
    fplusC = 4
    fzeroC = 8
    fspaceC = 16
    fwidthC = 32
    fprecC = 64
    fprec0C = 128
    default_float_precision = 6
    retry_exception = ::Opal::RetryException

    scanned = 0
    width = prec = nil
    flags = fnoneC
    nextarg = 1
    posarg = 0
    nextvalue = tmp = str = hash = nil

    argc = args.size

    # just like in ruby/sprintf.c
    get_next_arg = ->() do
      raise(::ArgumentError, "unnumbered(#{nextarg}) mixed with numbered") if posarg == -1
      raise(::ArgumentError, "unnumbered(#{nextarg}) mixed with named") if posarg == - 2
      posarg = nextarg
      # args count from 0, posarg counts from 1
      raise(::ArgumentError, 'too few arguments') if posarg > argc
      nextarg += 1
      args[posarg - 1]
    end

    # just like in ruby/sprintf.c
    get_arg = ->() do
      return nextvalue if nextvalue
      get_next_arg.()
    end

    # just like in ruby/sprintf.c
    get_pos_arg = ->(n) do
      raise(::ArgumentError, "numbered(#{n}) after unnumbered(#{posarg})") if posarg > 0
      raise(::ArgumentError, "numbered(#{n}) after named") if posarg == -2
      raise(::ArgumentError, "invalid index - #{n}") if n < 1
      # args count from 0, n counts from 1
      raise(::ArgumentError, 'too few arguments') if n > argc
      posarg = -1
      args[n - 1]
    end

    # just like in ruby/sprintf.c
    get_num = ->(ppi) do
      num_s = `format_string.slice(ppi)`
      num_m = `num_s.match(/^\d+/)`
      if num_m
        num_s = num_m[0]
        raise(::ArgumentError, 'malformed format string - %%*[0-9]') if ppi + `num_s.length` >= `format_string.length`
        [ppi + `num_s.length`, num_s.to_i]
      else
        [ppi, nil]
      end
    end

    # just like in ruby/sprintf.c
    get_hash = ->(hash, ac, av) do
      return hash if hash
      raise(::ArgumentError, 'one hash required') if ac != 1
      tmp = av[0]
      tmp.to_hash rescue nil
    end

    get_aster = ->(ppi, val) do
      t = ppi
      ppi += 1
      ppi, n = get_num.(ppi)
      if `format_string[ppi] == '$'`
        tmp = get_pos_arg.(n)
      else
        tmp = get_next_arg.()
        ppi = t
      end
      [ppi, tmp.to_int]
    end

    # just like in ruby/sprintf.c
    check_for_width = ->(f) do
      raise(::ArgumentError, 'width given twice') if f & fwidthC == fwidthC
      raise(::ArgumentError, 'width after precision') if f & fprec0C == fprec0C
    end

    # just like in ruby/sprintf.c
    check_for_flags = ->(f) do
      raise(::ArgumentError, 'flag after width') if f & fwidthC == fwidthC
      raise(::ArgumentError, 'flag after precision') if f & fprec0C == fprec0C
    end

    # just like in ruby/sprintf.c
    check_name_arg = ->(name) do
      raise(::ArgumentError, "named #{name} after unnumbered(#{posarg})") if posarg > 0
      raise(::ArgumentError, "named #{name} after numbered") if posarg == -1
      posarg = -2
    end

    # just like in ruby/sprintf.c
    filll = ->(c, l) do
      while l > 0
        `result += c`
        l -= 1
      end
    end

    # just like in ruby/sprintf.c
    push = ->(s, i, e) { `result += (i > 0 || (i + e) < s.length) ? s.slice(i, i + e) : s` }

    # this is the label format_s1 from rb_str_format extracted as lambda
    format_s1 = -> (prec) do
      len = `str.length`
      if enc != str.encoding
        enc = str.encoding unless enc.ascii_compatible? && str.ascii_only?
      end
      if (flags & fprecC == fprecC) || (flags & fwidthC == fwidthC)
        slen = str.length # consider encoding
        raise(::ArgumentError, 'invalid mbstring sequence') unless str.valid_encoding?
        if (flags & fprecC == fprecC) && (prec < slen)
          ps = str.slice(0, prec) # consider encoding
          slen = prec
          len = `ps.length`
        end
        # need to adjust multi-byte string pos
        if (flags & fwidthC == fwidthC) && (width > slen)
          width -= slen
          if !(flags & fminusC == fminusC)
            filll.(' ', width)
            width = 0
          end
          push.(str, 0, len)
          filll.(' ', width) if flags & fminusC == fminusC
          return width
        end
      end
      push.(str, 0, len)
      width
    end

    # this is the label format_s from rb_str_format extracted as lambda
    format_s = ->(prec) do
      arg = get_arg.()
      str = `format_string[pi] == 'p'` ? arg.inspect : arg.to_s
      format_s1.(prec)
    end

    # just like in ruby/bignum.c
    # returning [numwords, nlz_bits]
    rb_absint_numwords = ->(val, word_numbits) do
      val_numbits = val.abs.bit_length
      div, mod = val_numbits.divmod(word_numbits)
      numwords = mod == 0 ? div : div + 1
      [numwords, numwords * word_numbits - val_numbits]
    end

    # just like in ruby/sprintf.c
    sign_bits = ->(base, pc) do
      case base
      when 16
        return `pc == 'X'` ? 'F' : 'f'
      when 8
        return '7'
      when 2
        return '1'
      end
      return '.'
    end

    val_str = -> (val, numdigits, numbits, base) do
      if val < 0
        if (flags & fspaceC == fspaceC) || (flags & fplusC == fplusC)
          val.abs.to_s(base)
        else
          negmask = (1 << ((numdigits + 1) * numbits)) - 1
          lowmask = (1 << ((numdigits > 1 ? numdigits - 1 : 1) * numbits)) - 1
          c_val = val & negmask
          c_val = val & ((1 << (numdigits * numbits)) - 1) if c_val > (negmask - lowmask)
          c_val.to_s(base)
        end
      else
        val.to_s(base)
      end
    end

    # this is the label bin_retry from rb_str_format extracted as lambda
    bin_retry = ->(val, sign, prefix) do
      val = ::Kernel.Integer(val)
      valsign = val < 0 ? -1 : 1
      sc = nil
      dots = false

      base =  case `format_string[pi]`
              when 'o'
                8
              when 'x', 'X'
                16
              when 'b', 'B'
                2
              when 'u', 'd', 'i'
                10
              else
                10
              end

      if base != 10
        numbits = base.bit_length - 1
        numdigits, abs_nlz_bits = rb_absint_numwords.(val, numbits)
        # INT_MAX is used because rb_long2int is used later.
        raise(::ArgumentError, 'size too big') if `Number.MAX_SAFE_INTEGER - 1` < numdigits

        if sign
          numdigits += 1 if numdigits == 0
          tmp = val_str.(val, numdigits, numbits, base)
          if valsign < 0
            sc = '-'
            width -= 1
          elsif flags & fplusC == fplusC
            sc = '+'
            width -= 1
          elsif flags & fspaceC == fspaceC
            sc = ' '
            width -= 1
          end
        else
          numdigits += 1 if numdigits == 0 || (abs_nlz_bits != (numbits - 1))
          tmp = val_str.(val, numdigits, numbits, base)
          dots = valsign < 0
        end
      else
        tmp = val.abs.to_s(10)
        if valsign < 0
          sc = '-'
          width -= 1
        elsif flags & fplusC == fplusC
          sc = '+'
          width -= 1
        elsif flags & fspaceC == fspaceC
          sc = ' '
          width -= 1
        end
      end
      len = `tmp.length`

      if dots
        prec -= 2
        width -= 2
      end

      if `format_string[pi] == 'X'`
        tmp = tmp.upcase
      end

      if prefix && `!prefix[1]` # octal
        if dots
          prefix = nil
        elsif len == 1 && `tmp[0] == '0'`
          len = 0
          prec -= 1 if flags & fprecC == fprecC
        elsif (flags & fprecC == fprecC) && (prec > len)
          prefix = nil
        end
      elsif len == 1 && `tmp[0] == '0'`
        prefix = nil
      end

      width -= `prefix.length` if prefix

      if flags & (fzeroC|fminusC|fprecC) == fzeroC
        prec = width
        width = 0
      else
        if prec < len
          len = 0 if !prefix && prec == 0 && len == 1 && `tmp[0] == '0'`
          prec = len
        end
        width -= prec
      end

      if !(flags & fminusC == fminusC)
        filll.(' ', width)
        width = 0
      end
      push.(sc, 0, 1) if sc
      push.(prefix, 0, `prefix.length`) if prefix
      push.("..", 0, 2) if dots
      if prec > len
        if !sign && valsign < 0
          c = sign_bits.(base, `format_string[pi]`)
          filll.(c, prec - len)
        elsif (flags & (fminusC|fprecC)) != fminusC
          filll.('0', prec - len)
        end
      end
      push.(tmp, 0, len)
      filll.(' ', width)
    end

    del_dot_zero = ->(s) do
      if `s.indexOf('.')` != -1
        last_i = `s.length - 1`
        while `s[last_i] == '0'`
          last_i -= 1
        end
        last_i -= 1 if `s[last_i] == '.'`
        s = `s.slice(0, last_i + 1)` if last_i < `s.length - 1`
      end
      s
    end

    # this is the label float_value from rb_str_format extracted as lambda
    float_value = ->(prec) do
      val = get_arg.()
      val = ::Kernel.Float(val)
      fc = ' '
      sign =  if !val.nan? && val < 0.0
                '-'
              elsif flags & fplusC == fplusC
                '+'
              elsif flags & fspaceC == fspaceC
                ' '
              else
                nil
              end
      if !val.finite?
        tmp = val.nan? ? "NaN" : "Inf"
      else
        val = val.abs
        prc = prec == -1 ? default_float_precision : prec
        fc = '0' if flags & fzeroC == fzeroC
        case `format_string[pi]`
        when 'f'
          tmp = `val.toFixed(prc)`
          tmp += '.' if flags & fsharpC == fsharpC && `tmp.indexOf('.')` == -1
        when 'e', 'E'
          tmp = `val.toExponential(prc)`
          tflt, texp = `tmp.split('e')`
          exp = texp.to_i
          texp = format('%+.2d', exp)
          tflt += '.' if flags & fsharpC == fsharpC && `tflt.indexOf('.')` == -1
          tmp = `tflt + (format_string[pi] == 'E' ? 'E' : 'e') + texp`
        when 'g', 'G'
          tmp = `val.toExponential(prc)`
          tflt, texp = `tmp.split('e')`
          exp = texp.to_i
          prc = 1 if prc < 1
          if exp < -4 || exp >= prc
            flt = tflt.to_f
            texp = format('%+.2d', exp)
            tflt = `flt.toPrecision(prc)`
            if flags & fsharpC == fsharpC
              tflt += '.' if `tflt.indexOf('.')` == -1
            else
              tflt = del_dot_zero.(tflt) if prec == -1
            end
            tmp = `tflt + (format_string[pi] == 'G' ? 'E' : 'e') + texp`
          else
            tmp = `val.toPrecision(prc)`
            if flags & fsharpC == fsharpC
              tmp += '.' if `tmp.indexOf('.')` == -1
            else
              tmp = del_dot_zero.(tmp)
            end
          end
        when 'a', 'A'
          if `format_string[pi] == 'a'`
            pp = 'p'
            xx = 'x'
          else
            pp = 'P'
            xx = 'X'
          end
          flt = val
          exp = 0
          if flt < 1
            while flt < 1
              flt *= 2
              exp -= 1
            end
          else
            while flt >= 2
              flt /= 2
              exp += 1
            end
          end
          tflt = `flt.toString(16)`
          tflt = tflt.upcase if `xx == 'X'`
          dot_idx = `tflt.indexOf('.')`
          if dot_idx > 0
            tflt = `tflt.slice(0, dot_idx + 1 + prc)` if prec != -1 && `tflt.length - dot_idx` > prc
            if prc > 0
              while `tflt.length - dot_idx` <= prc
                tflt = `tflt + '0'`
              end
            end
          end
          if flags & fsharpC == fsharpC
            tflt += '.' if `tflt.indexOf('.')` == -1
          else
            tflt = del_dot_zero.(tflt) if prec == -1
          end
          tmp = tflt + pp + (exp < 0 ? '' : '+') + `exp.toString(10)`
          if (flags & fwidthC == fwidthC)
            need = `tmp.length + 2`
            need += 1 if sign
            need = width - need
          else
            need = -1
          end
          if flags & fminusC == fminusC
            push.(sign, 0, 1) if sign
            push.('0' + xx, 0, 2)
            push.(tmp, 0, `tmp.length`)
            filll.(' ', need) if need > 0
          else
            if flags & fzeroC == fzeroC
              push.(sign, 0, 1) if sign
              push.('0' + xx, 0, 2)
              filll.('0', need) if need > 0
              push.(tmp, 0, `tmp.length`)
            else
              filll.(' ', need) if need > 0
              push.(sign, 0, 1) if sign
              push.('0' + xx, 0, 2)
              push.(tmp, 0, `tmp.length`)
            end
          end
          return
        end
      end
      if (flags & fwidthC == fwidthC)
        need = `tmp.length`
        need += 1 if sign
        need = width - need
      else
        need = -1
      end
      if flags & fminusC == fminusC
        push.(sign, 0, 1) if sign
        push.(tmp, 0, `tmp.length`)
        filll.(' ', need) if need > 0
      else
        filll.(fc, need) if need > 0
        push.(sign, 0, 1) if sign
        push.(tmp, 0, `tmp.length`)
      end
    end

    # just like in ruby/sprintf.c, not doing much
    sprint_exit = ->() do
      # We cannot validate the number of arguments if (digit)$ style used.
      # if (posarg >= 0 && nextarg < argc && !(argc == 2 && args[1].is_a?(::Hash)))
      #   mesg = "too many arguments for format string"
      #   raise(::ArgumentError, "%s", mesg) if (RTEST(ruby_debug))
      #   warn("%s", mesg) if (RTEST(ruby_verbose))
      # end

      `Opal.str(result, enc)`
    end

    while (pi += 1) < pe
      n = sym = nil
      t = pi
      while t < pe && `format_string[t] != '%'`
        t += 1
      end

      raise(::ArgumentError, 'incomplete format specifier; use %%%% (double %%) instead') if (t + 1 == pe)

      push.(format_string, pi, t - pi)

      if t >= pe # end of format_string string
        # break
        #
        # Bug #2743 in Opal, because the while body gets wrapped in a function the return below
        # does not return the method but instead the function wrapper causing another loop run.
        # Overall just using `break` instead here should be sufficient. But due to this bug,
        # that would lead to 'SyntaxError: Illegal break statement'.
        # So at this moment we have to set pi to t and return the function, causing another loop
        # that will not run because the end of format string is reached, doing the return at method end below.
        # If the bug gets fixed, the return may actually return, so we better call sprint_exit.
        # So for the moment, sprint exit is called twice, here and below at method end and actual return.
        pi = t
        return sprint_exit.()
      end

      pi = t + 1 # skip `%'

      width = prec = -1
      nextvalue = nil

      begin
        case `format_string[pi] || nil`
        when ' '
          check_for_flags.(flags)
          flags |= fspaceC
          pi += 1
          raise retry_exception

        when '#'
          check_for_flags.(flags)
          flags |= fsharpC
          pi += 1
          raise retry_exception

        when '+'
          check_for_flags.(flags)
          flags |= fplusC
          pi += 1
          raise retry_exception

        when '-'
          check_for_flags.(flags)
          flags |= fminusC
          pi += 1
          raise retry_exception

        when '0'
          check_for_flags.(flags)
          flags |= fzeroC
          pi += 1
          raise retry_exception

        when '1', '2', '3', '4', '5', '6', '7', '8', '9'
          pi, n = get_num.(pi)
          if `format_string[pi] == '$'`
            raise(::ArgumentError, "value given twice - #{n}") if !nextvalue.nil?
            nextvalue = get_pos_arg.(n)
            pi += 1
            raise retry_exception
          end
          check_for_width.(flags)
          width = n
          flags |= fwidthC
          raise retry_exception

        when '<', '{'
          start = pi
          term = (`format_string[pi] == '<'`) ? '>' : '}'
          pi += 1 # skip '<' or '{'
          while pi < pe && `format_string[pi] != term`
            pi = `Opal.mbinc(format_string, pi)`
          end

          raise(::ArgumentError, 'malformed name - unmatched parenthesis') if pi >= pe

          len = pi - start + 1 # including parenthesis
          raise(::ArgumentError, "named #{`format_string.slice(start)`} after <#{sym}>") if sym != nil
          hash = get_hash.(hash, argc, args)
          sym = `format_string.slice(start + 1, start + len - 1)`.to_sym
          # ^ without parenthesis
          check_name_arg.(sym)
          if !sym.nil?
            raise(::KeyError.new("key #{sym} not found", receiver: hash, key: sym)) unless hash.key?(sym)
            nextvalue = hash[sym]
          end
          if (term == '}')
            width = format_s.(prec)
          else
            pi += 1
            raise retry_exception
          end

        when '*'
          check_for_width.(flags)
          flags |= fwidthC
          pi, width = get_aster.(pi, width)
          if (width < 0)
            flags |= fminusC
            width = -width
            raise(::ArgumentError, 'width too big') if width < 0
          end
          pi += 1
          raise retry_exception

        when '.'
          raise(::ArgumentError, 'precision given twice') if flags & fprec0C == fprec0C

          flags |= fprecC|fprec0C

          prec = 0
          pi += 1
          if `format_string[pi] == '*'`
            pi, prec = get_aster.(pi, prec)
            flags &= ~fprecC if (prec < 0) # ignore negative precision
            pi += 1
            raise retry_exception
          end

          pi, prec = get_num.(pi)
          raise(::ArgumentError, 'precision too big') if `Number.MAX_SAFE_INTEGER - 1` < prec
          raise retry_exception

        when '%'
          raise(::ArgumentError, 'invalid format character - %%') if flags != fnoneC
          push.(format_string, pi, 1)

        when 'c'
          val = get_arg.()
          c = nil
          if val
            tmp = val.to_str rescue nil
          end
          if !tmp.nil?
            raise(::TypeError) unless tmp.class == ::String
            flags |= fprecC
            prec = 1
            str = tmp
            width = format_s1.(prec)
          else
            n = ::Opal.coerce_to!(val, ::Integer, :to_int)
            if n >= 0
              c = n
              chr = `String.fromCodePoint(c)`
              n = `chr.length` rescue nil
            end
            raise(::ArgumentError, 'invalid character') if n.nil?

            # encidx = rb_ascii8bit_appendable_encoding_index(enc, c)
            # if encidx >= 0 && encidx != rb_enc_to_index(enc)
            #   # special case
            #   rb_enc_associate_index(result, encidx)
            #   enc = rb_enc_from_index(encidx)
            #   coderange = ENC_CODERANGE_VALID
            # end
            if !(flags & fwidthC == fwidthC)
              push.(chr, 0, `chr.length`)
            elsif flags & fminusC == fminusC
              width -= 1
              push.(chr, 0, `chr.length`)
              filll.(' ', width) if width > 0
            else
              width -= 1
              filll.(' ', width) if width > 0
              push.(chr, 0, `chr.length`)
            end
          end

        when 's', 'p'
          width = format_s.(prec)

        when 'd', 'i', 'o', 'x', 'X', 'b', 'B', 'u'
          val = get_arg.()
          valsign = nil
          s = nil
          prefix = nil
          sign = false

          case `format_string[pi]`
          when 'd', 'i', 'u'
            sign = true
          when 'o', 'x', 'X', 'b', 'B'
            sign = true if (flags & fplusC == fplusC) || (flags & fspaceC == fspaceC)
          end

          if flags & fsharpC == fsharpC
            prefix =  case `format_string[pi]`
                      when 'o'
                        '0'
                      when 'x'
                        '0x'
                      when 'X'
                        '0X'
                      when 'b'
                        '0b'
                      when 'B'
                        '0B'
                      end
          end

          bin_retry.(val, sign, prefix)

        when 'f'
          val = get_arg.()
          num = den = nil
          prec = default_float_precision if !(flags & fprecC == fprecC)

          if val.is_a?(::Integer)
            den = 1
            num = val
          elsif val.is_a?(::Rational)
            den = val.denominator
            num = val.numerator
          else
            nextvalue = val
            float_value.(prec)
            next
          end

          sign = flags & fplusC == fplusC ? 1 : 0
          zero = 0
          len = fill = 0
          if num < 0
            sign = -1
            num = num.abs
          end
          if den != 1
            num = num * (10**prec)
            num = num + (den/2).to_i
            num = (num/den).to_i
          elsif prec >= 0
            zero = prec
          end
          val = num.to_s
          len = `val.length` + zero
          len = prec + 1 if prec >= len # integer part 0
          len += 1 if sign != 0 || (flags & fspaceC == fspaceC)
          len += 1 if prec > 0 # period
          fill = width > len ? width - len : 0
          filll.(' ', fill) if fill && !(flags & (fminusC|fzeroC) == (fminusC|fzeroC))
          if sign != 0 || (flags & fspaceC == fspaceC)
            push.(sign > 0 ? '+' : sign < 0 ? '-' : ' ', 0, 1)
          end
          filll.('0', fill) if fill && (flags & (fminusC|fzeroC) == fzeroC)
          len = `val.length` + zero
          t = val
          if (len > prec)
            push.(t, 0, len - prec)
          else
            push.('0', 0, 1)
          end
          push.('.', 0, 1) if prec > 0
          if zero
            filll.('0', zero)
          elsif prec > len
            filll.('0', prec - len)
            push.(t, 0, len)
          elsif prec > 0
            push.(t + len - prec, 0, prec)
          end
          filll.(' ', fill) if fill && (flags & fminusC == fminusC)

        when 'g', 'G', 'e', 'E', 'a', 'A'
          float_value.(prec)
          # TODO: rational support

        else
          if /[[:graph:]]/.match?(format_string[pi])
            raise(::ArgumentError, "malformed format string - %%#{format_string[pi]}")
          else
            raise(::ArgumentError, 'malformed format string')
          end
        end
      rescue ::Opal::RetryException
        retry
      end
      flags = fnoneC
    end
    sprint_exit.()
  end

  alias sprintf format
end
