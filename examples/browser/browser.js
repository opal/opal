opal.register('browser.rb', function($runtime, self, __FILE__) { $$init();
self.$m$puts("Hello, world! Running in the browser..");


"All code is generated to keep the same line as the original ruby";
self.$m$puts(("This code is generated from line " + (6).m$to_s() + ", in file: " + __FILE__.m$to_s()));


title = document.title;
self.$m$puts(("The document title is '" + title.m$to_s() + "'"));


(($B.p = function(a) { var self = this;var $A = arguments, $L = $A.length; var __a;if (a === undefined) { a = nil; }
  return self.$m$puts(a);
}).$proc = [self], $B.f = (__a = [1, 2, 3, 4, 5]).m$each).call(__a);


$class(self, nil, 'ClassA', function(self) {
  return $def(self, 'method_missing', function(method_id, args) { var self = this;var __a, __b, __c;var $A = arguments, $M = $A.callee, $L = $A.length;if ($L < 1) { $ac(1, $L - 1); }args = [].slice.call($A, 1);
    return self.$m$puts(("Tried to call '" + method_id.m$to_s() + "' with: " + args.m$inspect().m$to_s()));
  }, 0);
}, 0);

self['@cls'] = $cg(self, 'ClassA').m$new();
self['@cls'].m$try_this();
self['@cls']['m$do_assign=']("this won't work");
self['@cls']['m$[]=']('neither', $symbol('will_this'));
self['@cls']['m$is_this_true?']();
self['@cls']['m$no_its_not!']();
self['@cls']['m$+']('something to add');


self.$m$puts((1)['m$+'](2));
self.$m$puts([1, 2, 3, 4]['m$[]'](0));
self.$m$puts([1, 2, 3, 4]['m$[]'](-2));


$class(self, $cg(self, 'Exception'), 'CustomBrowserException', function(self) {  return nil;}, 0);

try {
  self.$m$raise($cg(self, 'CustomBrowserException'), "some error happened");} catch (__err__) {
  if (true){e = __err__;
    self.$m$puts("caught error:");
    self.$m$puts(e.m$inspect());}
};

var nil, $ac, $super, $break, $class, $def, $symbol, $range, $hash, $B, Qtrue, Qfalse, $cg;var __a, __b, title, e;
function $$init() {nil = $runtime.Qnil, $ac = $runtime.ac, $super = $runtime.S, $break = $runtime.B, $class = $runtime.dc, $def = $runtime.dm, $symbol = $runtime.Y, $range = $runtime.G, $hash = $runtime.H, $B = $runtime.P, Qtrue = $runtime.Qtrue, Qfalse = $runtime.Qfalse, $cg = $runtime.cg;$runtime.mm(['puts', 'to_s', 'each', 'inspect', 'new', 'try_this', 'do_assign=', '[]=', 'is_this_true?', 'no_its_not!', '+', '[]', 'raise']);if (self['@cls'] == undefined) { self['@cls'] = nil; }}
 });
opal.require('browser');
