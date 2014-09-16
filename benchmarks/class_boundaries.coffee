
rb_create_class = (name, superclass = null) ->
  class TopProto
  class BottomProto extends TopProto

  rb_klass = {
    top_proto: TopProto
    bottom_proto: BottomProto
    superclass: null
    included_modules: []
  }

  rb_update_inheritance_chain(rb_klass)

  return rb_klass


rb_include = (klass, module) ->
  klass.included_modules.push module
  klass.update_modules

rb_update_inheritance_chain(klass)
  module_copies_list = [klass.top_proto]
  klass.included_modules.each (module)->
    module_copy = duplicate_module(module)
    set_super_prototype(base: module_copy, parent: module_copies_list.last())
  set_super_prototype(base: klass.bottom_proto, parent: module_copies_list.last())

set_super_prototype(kwargs)
  base = kwargs.base
  parent = kwargs.parent
  base.prototype

duplicate_module(module)->
  module_copy = {}
  for method in module
    module_copy[method] = module[method]
  module_copy
