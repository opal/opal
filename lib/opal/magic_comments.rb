# frozen_string_literal: true

module Opal::MagicComments
  MAGIC_COMMENT_RE = /\A# *(\w+) *: *(\S+.*?) *$/.freeze
  EMACS_MAGIC_COMMENT_RE = /\A# *-\*- *(\w+) *: *(\S+.*?) *-\*- *$/.freeze

  def self.parse(sexp, comments)
    flags = {}

    # We have an upper limit at the first line of code
    if sexp
      first_line = sexp.loc.line
      comments = comments.take(first_line)
    end

    comments.each do |comment|
      next if first_line && comment.loc.line >= first_line

      if (parts = comment.text.scan(MAGIC_COMMENT_RE)).any? ||
         (parts = comment.text.scan(EMACS_MAGIC_COMMENT_RE)).any?
        parts.each do |key, value|
          flags[key.to_sym] =
            case value
            when 'true' then true
            when 'false' then false
            else value
            end
        end
      end
    end

    flags
  end
end
