opal_filter "Symbol" do
  fails "Symbol#to_proc sends self to arguments passed when calling #call on the Proc"
  fails "Symbol#to_proc raises an ArgumentError when calling #call on the Proc without receiver"
  fails "Symbol#to_proc passes along the block passed to Proc#call"
end
