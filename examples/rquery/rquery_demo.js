opal.register('rquery_demo.js', function(VM, self, __FILE__) { var nil = VM.Qnil, $arg = VM.ac, $class = VM.dc, $def = VM.dm, $symbol = VM.Y, $hash = VM.H, $block = VM.P, Qtrue = VM.Qtrue, Qfalse = VM.Qfalse;VM.mm(['require', 'ready?', 'include', '[]', 'click', 'alert', 'add_class', 'find', 'each', 'puts', 'html']);var __a, __b;
(__a = self).$m.require(__a, 'rquery');


(__a = VM.gg('$document'), __b = [__a], ($block.p = function(self) {  return nil;

}).$self = self, ($block.f = __a.$m['ready?']).apply(__a, __b));


(__b = self).$m.include(__b, rb_vm_cg(self, 'RQuery'));


(__b = rb_vm_cg(self, 'Document'), __a = [__b], ($block.p = function(self) {  return nil;

}).$self = self, ($block.f = __b.$m['ready?']).apply(__b, __a));


(__a = VM.gg('$document'), __b = [__a], ($block.p = function(self) { var __a, __b;
  return (__a = (__b = VM.gg('$document')).$m['[]'](__b, 'a'), __b = [__a], ($block.p = function(self) { var __a;    return (__a = self).$m.alert(__a, "Hello world!");}).$self = self, ($block.f = __a.$m.click).apply(__a, __b));
}).$self = self, ($block.f = __a.$m['ready?']).apply(__a, __b));


(__b = VM.gg('$document'), __a = [__b], ($block.p = function(self) { var __a, __b, __c, __d;
  return (__a = (__b = (__c = (__d = VM.gg('$document')).$m['[]'](__d, '#orderedlist')).$m.add_class(__c, 'red')).$m.find(__b, 'li')).$m.add_class(__a, 'blue');
}).$self = self, ($block.f = __b.$m['ready?']).apply(__b, __a));


(__a = VM.gg('$document'), __b = [__a], ($block.p = function(self) { var __a, __b;
  return (__a = (__b = VM.gg('$document')).$m['[]'](__b, 'li'), __b = [__a], ($block.p = function(self, elem) { var __a, __b;if (elem === undefined) { elem = nil; }    return (__a = self).$m.puts(__a, (__b = elem).$m.html(__b));}).$self = self, ($block.f = __a.$m.each).apply(__a, __b));
}).$self = self, ($block.f = __a.$m['ready?']).apply(__a, __b));

(__b = VM.gg('$document'), __a = [__b], ($block.p = function(self) { var __a, __b;
  return (__a = VM.gg('$document'), __b = [__a], ($block.p = function(self) { var __a;
    return (__a = self).$m.puts(__a, "clicked doc!");
  }).$self = self, ($block.f = __a.$m.click).apply(__a, __b));
}).$self = self, ($block.f = __b.$m['ready?']).apply(__b, __a)); });
opal.require('rquery_demo');
