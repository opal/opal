# frozen_string_literal: true

# backtick_javascript: true
# use_strict: true

module Opal
  module RegexpTranspiler
    module_function

    # Transform a regular expression from Ruby syntax to JS syntax, as much
    # as possible.
    def transform_regexp(original_regexp, flags)
      flags ||= ''

      if include?(flags, 'm')
        ruby_multiline = true
        flags = remove_flag(flags, 'm')
      end

      flags = add_flag(flags, 'u') # always be unicode aware to handle surrogates correctly

      # First step - easy replacements
      regexp = transform_regexp_by_re_and_hash(original_regexp, ESCAPES_REGEXP, Opal::REGEXP_EQUIVALENTS)

      # Tokenize the regexp into tokens of `[]` and anything else.
      escaping = false
      str = ''
      depth = 0
      inside = false
      curr_inside = false
      new_regexp = ''
      line_based_regexp = false
      string_based_regexp = false
      unicode_character = false
      unicode_character_class = false
      quantifier = false

      apply_outside_transform = -> do
        unless curr_inside
          str = transform_regexp_by_re_and_hash(str, OUTSIDE_ESCAPES_REGEXP, Opal::REGEXP_EQUIVALENTS_OUTSIDE)
        end
        new_regexp += str
      end

      length = RUBY_ENGINE == 'opal' ? `regexp.length` : regexp.size
      i = 0

      while i < length
        char = RUBY_ENGINE == 'opal' ? `regexp[i]` : regexp[i]
        capture = true

        if escaping
          escaping = false
          if char == 'A' || char == 'z'
            string_based_regexp = true
          elsif char == 'p' || char == 'P'
            unicode_character_class = 1
          elsif char == 'u'
            unicode_character = 1
          end
        elsif char == '\\'
          escaping = true
        elsif depth == 0 && char == '.' && ruby_multiline
          # If user has specified //m modifier, it means it's expected for '.' to match
          # any character, including newlines
          char = '[\s\S]'
        elsif depth == 0 && (char == '^' || char == '$')
          # Line based regexp
          line_based_regexp = true
        elsif char == '['
          depth += 1
          # Skip additional ['s. This is important for expressions, that are valid in Ruby
          # like [[[:alnum:]]_]
          capture = false if depth > 1
        elsif char == ']'
          # Skip additional ]'s
          capture = false if depth > 1
          if depth <= 0
            # Re-add a [, since it is possible for that to happen.
            str = '[' + str
            depth = 0
          end
          depth -= 1
        elsif char == '{'
          # escape { to \\{ unless it belongs to
          # a unicode character class \p{...} or \P{...} or
          # a quantifier x{1}, x{1,} or x{1,2} or
          # a unicode character \u{...}
          if unicode_character_class == 1
            # look behind
            prev_chars = RUBY_ENGINE == 'opal' ? `regexp.slice(i-2)` : regexp[i - 2..i - 1]
            if prev_chars == '\\p' || prev_chars == '\\P'
              unicode_character_class = 2
            else
              unicode_character_class = false
              char = '\\{'
            end
          elsif unicode_character == 1
            # look behind
            prev_chars = RUBY_ENGINE == 'opal' ? `regexp.slice(i-2)` : regexp[i - 2..i - 1]
            if prev_chars == '\\u'
              unicode_character = 2
            else
              unicode_character = false
              char = '\\{'
            end
          elsif i > 0
            # look forward
            tail = RUBY_ENGINE == 'opal' ? `regexp.slice(i+1)` : regexp[i + 1..]
            if tail =~ /\A\d+(,|)\d*}/
              quantifier = true
            else
              char = '\\{'
            end
          else
            unicode_character_class = false
            unicode_character = false
            quantifier = false
            char = '\\{'
          end
        elsif char == '}'
          # escape } to \\} unless it belongs to
          # a unicode character class \p{...} or \P{...} or
          # a quantifier x{1}, x{1,} or x{1,2}
          if unicode_character_class == 2
            unicode_character_class = false
          elsif unicode_character == 2
            unicode_character = false
          elsif quantifier
            quantifier = false
          else
            unicode_character_class = false
            unicode_character = false
            quantifier = false
            char = '\\}'
          end
        end

        str += char if capture

        curr_inside = inside
        inside = depth > 0

        # Switching a token
        if curr_inside != inside
          # Since we are outside, let's apply a transformation
          apply_outside_transform.call
          str = ''
        end

        i += 1
      end

      apply_outside_transform.call

      # Set multiline flag to denote that ^ and $ should match both at borders of file
      # and at the borders of line. This will break if both \A and ^ are used in a single
      # regexp.
      flags = add_flag(flags, 'm') if line_based_regexp

      # Let's check for this case and warn appropriately
      if line_based_regexp && string_based_regexp
        warn "warning: Both \\A or \\z and ^ or $ used in a regexp #{original_regexp.inspect}. In Opal this will cause undefined behavior."
      end

      [new_regexp, flags]
    end

    if RUBY_ENGINE == 'opal'
      # rubocop: disable Lint/UnusedMethodArgument

      # Optimized version of helper functions, skipping the entire String#gsub shenanigans
      # and allowing to be used early in the bootstage.
      def transform_regexp_by_re_and_hash(regexp, transformer, hash)
        %x{
          return regexp.replace(transformer, function(i) {
            return hash.get(i) || i;
          });
        }
      end

      def add_flag(flags, flag)
        `flags.includes(flag) ? flags : flags + flag`
      end

      def remove_flag(flags, flag)
        `flags.replace(flag, '')`
      end

      # Are we sure the regexp is not using UTF-16 features?
      # This is a crude check.
      def simple_regexp?(regexp)
        `/^(\\[dnrtAzZ\\]|\(\?[:!]|[\w\s(){}|?+*@^$-])*$/.test(regexp)`
      end

      def include?(str, needle)
        `str.includes(needle)`
      end

      # rubocop:disable Style/MutableConstant
      ESCAPES_REGEXP = `/(\\.|\[:[a-z]*:\])/g`
      OUTSIDE_ESCAPES_REGEXP = `/(\\.)/g`
      # rubocop:enable Style/MutableConstant, Lint/UnusedMethodArgument
    else

      private

      def transform_regexp_by_re_and_hash(regexp, transformer, hash)
        regexp.gsub(transformer) do |i|
          hash[i] || i
        end
      end

      def add_flag(flags, flag)
        flags.include?(flag) ? flags : flags + flag
      end

      def remove_flag(flags, flag)
        flags.sub(flag, '')
      end

      # Are we sure the regexp is not using UTF-16 features?
      # TODO: This is a crude check. Revisit in the future.
      def simple_regexp?(regexp)
        /\A(\\[dnrtAzZ\\]|\(\?[:!]|[\w\s(){}|?+*@^$-])*\z/.match?(regexp)
      end

      def include?(str, needle)
        str.include?(needle)
      end

      ESCAPES_REGEXP = /(\\.|\[:[a-z]*:\])/
      OUTSIDE_ESCAPES_REGEXP = /(\\.)/
    end
  end
end
