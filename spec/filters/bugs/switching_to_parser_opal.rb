opal_filter "mspec_opal_nodejs suite" do
  fails "Operator calls compiles as a normal send method call"
  fails "The 'super' keyword with no arguments or parens passes the block to super"
  fails "The 'super' keyword with no arguments or parens passes the block to super on singleton methods"
  fails "Operator assignment 'obj.meth op= expr' evaluates lhs one time"
end
