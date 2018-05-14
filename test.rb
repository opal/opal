require 'corelib/marshal'

module M1; end
module M2; end

obj = /[a-z]/.extend(M1, M2)
new_obj = Marshal.load("\x04\bIe:\aM1e:\aM2/\n[a-z]\x00\x06:\x06EF")

p obj == new_obj
p     obj.singleton_class.ancestors
p new_obj.singleton_class.ancestors

# new_obj.should == obj
# new_obj_metaclass_ancestors = class << new_obj; ancestors; end
# new_obj_metaclass_ancestors[@num_self_class, 3].should ==
#   [Meths, MethsMore, Regexp]
