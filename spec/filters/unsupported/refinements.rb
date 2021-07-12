# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Refinements" do
  fails "Kernel#eval with refinements activates refinements from the binding" # NoMethodError: undefined method `refine' for #<Module:0x7ad6a>
  fails "Kernel#eval with refinements activates refinements from the eval scope" # NoMethodError: undefined method `refine' for #<Module:0x7ad6e>
end
