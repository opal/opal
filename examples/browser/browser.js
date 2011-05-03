opal.register('browser.js', function($runtime, self, __FILE__) { var nil = $runtime.Qnil, $ac = $runtime.ac, $super = $runtime.S, $break = $runtime.B, $class = $runtime.dc, $def = $runtime.dm, $symbol = $runtime.Y, $hash = $runtime.H, $block = $runtime.P, Qtrue = $runtime.Qtrue, Qfalse = $runtime.Qfalse;$runtime.mm(['puts', 'to_s', 'each', 'inspect', 'new', 'try_this', 'do_assign=', '[]=', 'is_this_true?', 'no_its_not!', '+', '[]', '-@', 'raise']);var __a, __b, title, __c, e;if (self['@cls'] == undefined) { self['@cls'] = nil; }
(__a = self).$m.$puts(__a, "Hello, world! Running in the browser..");


"All code is generated to keep the same line as the original ruby";
(__a = self).$m.$puts(__a, ("This code is generated from line " + (__b = 6).$m.to_s(__b) + ", in file: " + (__b = __FILE__).$m.to_s(__b)));


title = document.title;
(__a = self).$m.$puts(__a, ("The document title is '" + (__b = title).$m.to_s(__b) + "'"));


(__a = [1, 2, 3, 4, 5], __b = [__a], ($block.p = (__c = function(self, a) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a;if (a === undefined) { a = nil; }
  return (__a = self).$m.$puts(__a, a);
}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m.each).apply(__a, __b));


$class(self, nil, 'ClassA', function() { var self = this;
  return $def(self, 'method_missing', function(self, method_id, args) { var __a, __b, __c;var $args = arguments, $meth = $args.callee, $len = $args.length;if ($len < 2) { $ac(1, $len - 1); }args = [].slice.call($args, 2);
    return (__a = self).$m.$puts(__a, ("Tried to call '" + (__b = method_id).$m.to_s(__b) + "' with: " + (__b = (__c = args).$m.inspect(__c)).$m.to_s(__b)));
  }, 0);
}, 0);

self['@cls'] = (__b = rb_vm_cg(self, 'ClassA')).$m['new'](__b);
(__b = self['@cls']).$m.try_this(__b);
(__b = self['@cls']).$m['do_assign='](__b, "this won't work");
(__b = self['@cls']).$m['[]='](__b, 'neither', $symbol('will_this'));
(__b = self['@cls']).$m['is_this_true?'](__b);
(__b = self['@cls']).$m['no_its_not!'](__b);
(__b = self['@cls']).$m['+'](__b, 'something to add');


(__b = self).$m.$puts(__b, (__a = (1)).$m['+'](__a, 2));
(__b = self).$m.$puts(__b, (__a = [1, 2, 3, 4]).$m['[]'](__a, 0));
(__b = self).$m.$puts(__b, (__a = [1, 2, 3, 4]).$m['[]'](__a, (__c = (2)).$m['-@'](__c)));


$class(self, rb_vm_cg(self, 'Exception'), 'CustomBrowserException', function() { var self = this;  return nil;}, 0);

try {
  (__b = self).$m.$raise(__b, rb_vm_cg(self, 'CustomBrowserException'), "some error happened");} catch (__err__) {
  if (true){e = __err__;
    (__b = self).$m.$puts(__b, "caught error:");
    (__b = self).$m.$puts(__b, (__a = e).$m.inspect(__a));}
};
 });
opal.require('browser');
