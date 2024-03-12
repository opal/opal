# frozen_string_literal: true

module Opal
  # rubocop:disable Style/MutableConstant
  self::REGEXP_START = '\A'
  self::REGEXP_END = '\z'

  # Unicode characters in ranges
  # \u0001 - \u002F (blank unicode characters + space + !"#$%&'()*+,-./ chars)
  # \u003A - \u0040 (:;<=>?@ chars)
  # \u005B - \u005E ([\]^ chars)
  # \u0060          (` char)
  # \u007B - \u007F ({|}~ chars})
  # are not allowed to be used in identifier in the beggining or middle of its name
  self::FORBIDDEN_STARTING_IDENTIFIER_CHARS = '\u0001-\u002F\u003A-\u0040\u005B-\u005E\u0060\u007B-\u007F'

  # A map of some Ruby regexp patterns to their JS representations
  self::REGEXP_EQUIVALENTS = {
    '\h' => '[\dA-Fa-f]',
    '\e' => '\x1b',

    # Invalid cases in JS Unicode mode
    '\_' => '_',
    '\~' => '~',
    '\#' => '#',
    '\\\'' => "'",
    '\"' => '"',
    '\ ' => ' ',
    '\=' => '=',
    '\!' => '!',
    '\%' => '%',
    '\&' => '&',
    '\<' => '<',
    '\>' => '>',
    '\@' => '@',
    '\:' => ':',
    '\`' => '`',

    # POSIX classes
    '[:alnum:]' => '\p{Alphabetic}\p{Number}',   # Alphanumeric characters
    '[:alpha:]' => '\p{Alphabetic}',             # Alphabetic characters
    '[:blank:]' => '\p{Space_Separator}\t',      # Space and tab
    '[:cntrl:]' => '\p{Control}',                # Control characters
    '[:digit:]' => '\d',                         # Digits
    '[:graph:]' => '\p{Alphabetic}\p{Number}\p{Punctuation}\p{Symbol}', # Visible characters
    '[:lower:]' => '\p{Lowercase_Letter}', # Lowercase letters
    '[:print:]' => '\p{Alphabetic}\p{Number}\p{Punctuation}\p{Symbol}\p{Space_Separator}', # Visible characters and spaces
    '[:punct:]' => '\p{Punctuation}',            # Punctuation characters
    '[:space:]' => '\p{White_Space}',            # Whitespace characters
    '[:upper:]' => '\p{Uppercase_Letter}',       # Uppercase letters
    '[:xdigit:]' => '\dA-Fa-f',                  # Hexadecimal digits
  }

  # A map of some Ruby regexp patterns to their JS representations, but this set of
  # representations is only applied outside of `[` and `]`.
  self::REGEXP_EQUIVALENTS_OUTSIDE = {
    '\A' => '^',
    '\z' => '$',
    '\Z' => '(?:\n?$)',
    '\-' => '-',
    '\R' => '(?:\r|\n|\r\n|\f|\u0085|\u2028|\u2029)',
  }

  # Unicode characters in ranges
  # \u0001 - \u0020 (blank unicode characters + space)
  # \u0022 - \u002F ("#$%&'()*+,-./ chars)
  # \u003A - \u003E (:;<=> chars)
  # \u0040          (@ char)
  # \u005B - \u005E ([\]^ chars)
  # \u0060          (` char)
  # \u007B - \u007F ({|}~ chars})
  # are not allowed to be used in identifier in the end of its name
  # In fact, FORBIDDEN_STARTING_IDENTIFIER_CHARS = FORBIDDEN_ENDING_IDENTIFIER_CHARS + \u0021 ('?') + \u003F ('!')
  self::FORBIDDEN_ENDING_IDENTIFIER_CHARS = '\u0001-\u0020\u0022-\u002F\u003A-\u003E\u0040\u005B-\u005E\u0060\u007B-\u007F'
  self::INLINE_IDENTIFIER_REGEXP = Regexp.new("[^#{self::FORBIDDEN_STARTING_IDENTIFIER_CHARS}]*[^#{self::FORBIDDEN_ENDING_IDENTIFIER_CHARS}]")

  # For constants rules are pretty much the same, but ':' is allowed and '?!' are not.
  # Plus it may start with a '::' which indicates that the constant comes from toplevel.
  self::FORBIDDEN_CONST_NAME_CHARS = '\u0001-\u0020\u0021-\u002F\u003B-\u003F\u0040\u005B-\u005E\u0060\u007B-\u007F'
  self::CONST_NAME_REGEXP = Regexp.new("#{self::REGEXP_START}(::)?[A-Z][^#{self::FORBIDDEN_CONST_NAME_CHARS}]*#{self::REGEXP_END}")
  # rubocop:enable Style/MutableConstant
end
