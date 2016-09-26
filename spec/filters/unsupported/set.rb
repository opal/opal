opal_unsupported_filter "Set" do
  fails "Set#eql? returns true when the passed argument is a Set and contains the same elements"
  fails "Set#initialize is private"
end
