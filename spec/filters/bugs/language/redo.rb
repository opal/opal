opal_filter "redo" do
  fails "The redo statement re-executes the last step in enumeration"
  fails "The redo statement re-executes the closest loop"
  fails "The redo statement restarts block execution if used within block"
end
