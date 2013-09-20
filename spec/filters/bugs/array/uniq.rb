opal_filter "Array#uniq" do
  fails "Array#uniq compares elements based on the value returned from the block"
  fails "Array#uniq compares elements with matching hash codes with #eql?"
  fails "Array#uniq uses eql? semantics"
  fails "Array#uniq returns subclass instance on Array subclasses"
end

opal_filter "Array#uniq!" do
  fails "Array#uniq! compares elements based on the value returned from the block"
  fails "Array#uniq! properly handles recursive arrays"
end
