opal_filter "Enumerator" do
  fails "Enumerator.new accepts a block"
  fails "Enumerator.new ignores block if arg given"
  fails "Enumerator#rewind works with peek to reset the position"
  fails "Enumerator#rewind calls the enclosed object's rewind method if one exists"
end
