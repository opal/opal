opal_filter "Array#&" do
  fails "Array#& properly handles recursive arrays"
  fails "Array#& tries to convert the passed argument to an Array using #to_ary"
  fails "Array#& determines equivalence between elements in the sense of eql?"
end
