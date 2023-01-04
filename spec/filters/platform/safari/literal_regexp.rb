opal_unsupported_filter "Literal Regexp" do
  # Safari and WebKit do not support lookbehind, but may in the future see https://github.com/WebKit/WebKit/pull/7109
  fails "Literal Regexps handles a lookbehind with ss characters"
  fails "Literal Regexps supports (?<= ) (positive lookbehind)"
  fails "Literal Regexps supports (?<! ) (negative lookbehind)"
end
