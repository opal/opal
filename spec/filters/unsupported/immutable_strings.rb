opal_filter "immutable strings" do
  fails "Hash literal freezes string keys on initialization"
end
