# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Literal Regexp" do
  fails "Literal Regexps handles a lookbehind with ss characters"
  fails "Literal Regexps supports (?<! ) (negative lookbehind)"
  fails "Literal Regexps supports (?<= ) (positive lookbehind)"
end
