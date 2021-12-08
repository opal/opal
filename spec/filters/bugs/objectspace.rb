# NOTE: run bin/format-filters after changing this file
opal_filter "ObjectSpace" do
  fails "ObjectSpace._id2ref converts an object id to a reference to the object" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref raises RangeError when an object could not be found" # Expected RangeError but got: NoMethodError (undefined method `_id2ref' for ObjectSpace)
  fails "ObjectSpace._id2ref retrieves a String by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves a Symbol by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves a frozen literal String by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves a large Integer by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves a small Integer by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves an Encoding by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves false by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves nil by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace._id2ref retrieves true by object_id" # NoMethodError: undefined method `_id2ref' for ObjectSpace
  fails "ObjectSpace.define_finalizer allows multiple finalizers with different 'callables' to be defined" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.define_finalizer calls a finalizer at exit even if it is indirectly self-referencing" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.define_finalizer calls a finalizer at exit even if it is self-referencing" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.define_finalizer calls a finalizer defined in a finalizer running at exit" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.define_finalizer calls finalizer on process termination" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.define_finalizer warns if the finalizer has the object as the receiver" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.define_finalizer warns if the finalizer is a method bound to the receiver" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.define_finalizer warns if the finalizer was a block in the receiver" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2129a>
  fails "ObjectSpace.each_object calls the block once for each class, module in the Ruby process" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object calls the block once for each living, non-immediate object in the Ruby process" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object captured in an at_exit handler" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object captured in finalizer" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a fiber local" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a global variable" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a hash key" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a hash value" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a local variable captured in a Kernel#binding" # NoMethodError: undefined method `binding' for #<MSpecEnv:0x14f0c>
  fails "ObjectSpace.each_object finds an object stored in a local variable captured in a Proc#binding" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a local variable captured in a block explicitly" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a local variable captured in a block implicitly" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a local variable captured in by a method defined with a block" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a local variable set in a binding manually" # NoMethodError: undefined method `binding' for #<MSpecEnv:0x14f0c>
  fails "ObjectSpace.each_object finds an object stored in a local variable" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a second-level constant" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in a thread local" # NotImplementedError: Thread creation not available
  fails "ObjectSpace.each_object finds an object stored in a top-level constant" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in an array" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object finds an object stored in an instance variable" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object on singleton classes does not walk hidden metaclasses" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object on singleton classes walks singleton classes" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object returns an enumerator if not given a block" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.each_object walks a class and its normal descendants when passed the class's singleton class" # NoMethodError: undefined method `each_object' for ObjectSpace
  fails "ObjectSpace.garbage_collect accepts keyword arguments" # NoMethodError: undefined method `garbage_collect' for ObjectSpace
  fails "ObjectSpace.garbage_collect always returns nil" # NoMethodError: undefined method `garbage_collect' for ObjectSpace
  fails "ObjectSpace.garbage_collect can be invoked without any exceptions" # Expected to not get Exception but got: NoMethodError (undefined method `garbage_collect' for ObjectSpace)
  fails "ObjectSpace.garbage_collect doesn't accept any arguments" # Expected ArgumentError but got: NoMethodError (undefined method `garbage_collect' for ObjectSpace)
  fails "ObjectSpace.garbage_collect ignores the supplied block" # Expected to not get Exception but got: NoMethodError (undefined method `garbage_collect' for ObjectSpace)
  fails "ObjectSpace::WeakMap#[] matches using identity semantics" # Expected "x" == nil to be truthy but was false
  fails "ObjectSpace::WeakMap#each is correct" # NotImplementedError: #each can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#each_key is correct" # NotImplementedError: #each_key can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#each_key must take a block, except when empty" # NotImplementedError: #each can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#each_pair is correct" # NotImplementedError: #each_pair can't be implemented on top of JS inerfaces
  fails "ObjectSpace::WeakMap#each_value is correct" # NotImplementedError: #each_value can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#include? matches using identity semantics" # Exception: Invalid value used as weak map key
  fails "ObjectSpace::WeakMap#include? reports true if the pair exists and the value is nil" # NotImplementedError: #size can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#inspect displays object pointers in output" # Expected "#<ObjectSpace::WeakMap:0x1ceec>" =~ /^\#<ObjectSpace::WeakMap:0x\h+>$/ to be truthy but was nil
  fails "ObjectSpace::WeakMap#key? matches using identity semantics" # Exception: Invalid value used as weak map key
  fails "ObjectSpace::WeakMap#key? reports true if the pair exists and the value is nil" # NotImplementedError: #size can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#keys is correct" # NotImplementedError: #keys can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#length is correct" # NotImplementedError: #length can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#member? matches using identity semantics" # Exception: Invalid value used as weak map key
  fails "ObjectSpace::WeakMap#member? reports true if the pair exists and the value is nil" # NotImplementedError: #size can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#size is correct" # NotImplementedError: #size can't be implemented on top of JS interfaces
  fails "ObjectSpace::WeakMap#values is correct" # NotImplementedError: #values can't be implemented on top of JS interfaces
end
