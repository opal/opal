opal_filter "rescue" do
  fails "The rescue keyword parses  'a += b rescue c' as 'a += (b rescue c)'"
  fails "The rescue keyword will not rescue errors raised in an else block in the rescue block above it"
  fails "The rescue keyword will not execute an else block if an exception was raised"
  fails "The rescue keyword will execute an else block only if no exceptions were raised"
  fails "The rescue keyword will only rescue the specified exceptions when doing a splat rescue"
  fails "The rescue keyword can rescue a splatted list of exceptions"
  fails "The rescue keyword can rescue multiple raised exceptions with a single rescue block"
end
