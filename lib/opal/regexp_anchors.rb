module Opal
  REGEXP_START = RUBY_ENGINE == 'opal' ? '^' : '\A'.freeze
  REGEXP_END = RUBY_ENGINE == 'opal' ? '$' : '\z'.freeze

  # Unicode characters in ranges
  # \u0001 - \u0020 (blank unicode characters + space)
  # \u0022 - \u002F ("#$%&'()*+,-./ chars)
  # \u003A - \u003E (:;<=> chars)
  # \u0040          (@ char)
  # \u005B - \u005E ([\]^ chars)
  # \u0060          (` char)
  # \u007B - \u007F ({|}~ chars})
  # are not allowed to be used in identifier in any form
  # This regexp contains a common rule for filtering Ruby identifiers
  FORBIDDEN_IDENTIFIER_CHARS = "\\u0001-\\u0020\\u0022-\\u002F\\u003A-\\u003E\\u0040\\u005B-\\u005E\\u0060\\u007B-\\u007F"
  IDENTIFIER_REGEXP = Regexp.new("[^#{FORBIDDEN_IDENTIFIER_CHARS}]+")

  # For constants rules are pretty much the same, but ':' is allowed and '?!' are not.
  # Plus it may start with a '::' which indicates that the constant comes from toplevel.
  FORBIDDEN_CONST_NAME_CHARS = "\\u0001-\\u0020\\u0021-\\u002F\\u003B-\\u003F\\u0040\\u005B-\\u005E\\u0060\\u007B-\\u007F"
  CONST_NAME_REGEXP = Regexp.new("#{REGEXP_START}(::)?[A-Z][^#{FORBIDDEN_CONST_NAME_CHARS}]*#{REGEXP_END}")
end

