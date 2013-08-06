opal_filter "loop" do
  fails "The loop expression restarts the current iteration with redo"
  fails "The loop expression uses a spaghetti nightmare of redo, next and break"
end
