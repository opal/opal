opal_filter "immutable strings" do
  fails "Array#fill does not replicate the filler"

  fails "Hash literal freezes string keys on initialization"
end
