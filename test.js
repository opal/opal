// class A; end
// class B < A; end
// module M; end
// B.include(M)

Opal = {}
Opal.klass = function(name, superclass) {
  klass = function() {}
  klass.displayName = `Class_${name}`
  klass.prototype = {
    $$class: klass
  }
  if (superclass != null) {
    klass.prototype.__proto__ = superclass.prototype
  }
  return klass
}

Opal.def = function(klass, method_name, method_body) {
  klass.prototype[method_name] = method_body
}

Opal.append_features = function(module, includer) {
  module.prototype.__proto__ = {
    ...includer.prototype,
    __proto__: module.prototype.__proto__
  }
}

Class_A = Opal.klass('A') // no explicit superclass (must be Opal.Object)
Opal.def(Class_A, 'method_defined_in_A', function() {
  return 'method_defined_in_A'
})


Class_B = Opal.klass('B', Class_A)
Opal.def(Class_B, 'method_defined_in_B', function() {
  return 'method_defined_in_B'
})

a = new Class_A()
b = new Class_B()

// simple inheritance
console.log('a.method_defined_in_A', a.method_defined_in_A())
console.log('b.method_defined_in_A', b.method_defined_in_A())
console.log('b.method_defined_in_B', b.method_defined_in_B())

console.log()

function Module_M() {}
Module_M.prototype = {
  method_defined_in_M: function() { return 'method_defined_in_M' }
}

Opal.append_features(Class_B, Module_M);

console.log('b.method_defined_in_A', b.method_defined_in_A())
console.log('b.method_defined_in_B', b.method_defined_in_B())
console.log('b.method_defined_in_M', b.method_defined_in_M())
