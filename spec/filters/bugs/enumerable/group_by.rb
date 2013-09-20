opal_filter "Enumerable#group_by" do
  fails "Enumerable#group_by returns a hash without default_proc"
  fails "Enumerable#group_by returns an Enumerator if called without a block"
  fails "Enumerable#group_by gathers whole arrays as elements when each yields multiple"
end
