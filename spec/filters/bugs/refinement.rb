# NOTE: run bin/format-filters after changing this file
opal_filter "refinement" do
  fails "Refinement#import_methods doesn't import any methods if one of the arguments is not a module" # Expected TypeError but got: NoMethodError (undefined method `import_methods' for #<refinement:String@#<Module:0x42ca2>>)
  fails "Refinement#import_methods doesn't import methods from included/prepended modules" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42cb0>>
  fails "Refinement#import_methods doesn't import module's class methods" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42cbc>>
  fails "Refinement#import_methods imports methods from module so that methods can see each other" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42cb6>>
  fails "Refinement#import_methods imports methods from multiple modules so that methods see other's module's methods" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42caa>>
  fails "Refinement#import_methods imports module methods with super" # NoMethodError: undefined method `import_methods' for #<refinement:#<Class:0x42c8c>@#<Module:0x42c90>>
  fails "Refinement#import_methods warns if a module includes/prepends some other module" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42c9a>>
  fails "Refinement#import_methods when methods are defined in Ruby code imports a method defined in the last module if method with same name is defined in multiple modules" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42cd2>>
  fails "Refinement#import_methods when methods are defined in Ruby code imports methods from multiple modules" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42ccc>>
  fails "Refinement#import_methods when methods are defined in Ruby code imports methods" # NoMethodError: undefined method `import_methods' for #<refinement:String@#<Module:0x42ce2>>
  fails "Refinement#import_methods when methods are defined in Ruby code still imports methods of modules listed before a module that contains method not defined in Ruby" # Expected ArgumentError but got: NoMethodError (undefined method `import_methods' for #<refinement:String@#<Module:0x42cc4>>)
  fails "Refinement#import_methods when methods are defined in Ruby code throws an exception when argument is not a module" # Expected TypeError (wrong argument type Class (expected Module)) but got: NoMethodError (undefined method `import_methods' for #<refinement:String@#<Module:0x42cda>>)
  fails "Refinement#import_methods when methods are not defined in Ruby code raises ArgumentError when importing methods from C extension" # Expected ArgumentError (/Can't import method which is not defined with Ruby code: Zlib#*/) but got: NameError (uninitialized constant Zlib)
  fails "Refinement#import_methods when methods are not defined in Ruby code raises ArgumentError" # Expected ArgumentError but got: NoMethodError (undefined method `import_methods' for #<refinement:String@#<Module:0x42cf0>>)
  fails "Refinement#include raises a TypeError" # Expected TypeError (Refinement#include has been removed) but no exception was raised (#<refinement:String@#<Module:0x43ea8>> was returned)
  fails "Refinement#prepend raises a TypeError" # Expected TypeError (Refinement#prepend has been removed) but no exception was raised (#<refinement:String@#<Module:0x2ee12>> was returned)
end
