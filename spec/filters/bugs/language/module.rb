opal_filter "module" do
  fails "The module keyword raises a TypeError if the constant in nil"
  fails "The module keyword creates a new module with a variable qualified constant name"
  fails "The module keyword creates a new module with a qualified constant name"
  fails "The module keyword creates a new module with a non-qualified constant name"
end
