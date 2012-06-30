// // file lib/opal/spec/autorun.rb
// (function() {
// var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice;
// var __a, __b;
//   return (__b = __scope.Document, __b.$ready$p._p = (__a = function() {
// 
//     
//     
//     return (__scope.Spec)._scope.Runner.$new().$run()
//   }, __a._s = self, __a), __b.$ready$p())
// })();

// file lib/opal/spec/browser_formatter.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;

  return (function(__base){
    // line 1, lib/opal/spec/browser_formatter.rb, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, lib/opal/spec/browser_formatter.rb, class BrowserFormatter
      function BrowserFormatter() {};
      BrowserFormatter = __klass(__base, __super, "BrowserFormatter", BrowserFormatter);
      var BrowserFormatter_prototype = BrowserFormatter.prototype, __scope = BrowserFormatter._scope;
      BrowserFormatter_prototype.summary_element = BrowserFormatter_prototype.groups_element = BrowserFormatter_prototype.failed_examples = BrowserFormatter_prototype.group_element = BrowserFormatter_prototype.example_list = BrowserFormatter_prototype.example_group_failed = BrowserFormatter_prototype.examples = nil;

      __scope.CSS = "\n      body {\n        font-size: 14px;\n        font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\n      }\n\n      pre {\n        font-family: \"Bitstream Vera Sans Mono\", Monaco, \"Lucida Console\", monospace;\n        font-size: 12px;\n        color: #444444;\n        white-space: pre;\n        padding: 3px 0px 3px 12px;\n        margin: 0px 0px 8px;\n\n        background: #FAFAFA;\n        -webkit-box-shadow: rgba(0,0,0,0.07) 0 1px 2px inset;\n        -webkit-border-radius: 3px;\n        -moz-border-radius: 3px;\n        border-radius: 3px;\n        border: 1px solid #DDDDDD;\n      }\n\n      ul.example_groups {\n        list-style-type: none;\n      }\n\n      li.group.passed .group_description {\n        color: #597800;\n        font-weight: bold;\n      }\n\n      li.group.failed .group_description {\n        color: #FF000E;\n        font-weight: bold;\n      }\n\n      li.example.passed {\n        color: #597800;\n      }\n\n      li.example.failed {\n        color: #FF000E;\n      }\n\n      .examples {\n        list-style-type: none;\n      }\n    ";

      // line 52, lib/opal/spec/browser_formatter.rb, BrowserFormatter#initialize
      BrowserFormatter_prototype.$initialize = function() {
        
        this.examples = [];
        return this.failed_examples = [];
      };

      // line 57, lib/opal/spec/browser_formatter.rb, BrowserFormatter#start
      BrowserFormatter_prototype.$start = function() {
        var __a;
        if ((__a = __scope.Document.$body_ready$p()) === false || __a === nil) {
          this.$raise("Not running in browser")
        };
        this.summary_element = __scope.DOM.$parse("<p class=\"summary\"></p>");
        this.summary_element.$append_to_body();
        this.groups_element = __scope.DOM.$parse("<ul class=\"example_groups\"></ul>");
        this.groups_element.$append_to_body();
        return __scope.DOM.$parse("<style>" + __scope.CSS + "</style>").$append_to_head();
      };

      // line 69, lib/opal/spec/browser_formatter.rb, BrowserFormatter#finish
      BrowserFormatter_prototype.$finish = function() {
        var text = nil;
        text = "\n" + this.$example_count() + " examples, " + this.failed_examples.$size() + " failures";
        return this.summary_element.$html$e(text);
      };

      // line 75, lib/opal/spec/browser_formatter.rb, BrowserFormatter#example_group_started
      BrowserFormatter_prototype.$example_group_started = function(group) {
        
        this.example_group = group;
        this.example_group_failed = false;
        this.group_element = __scope.DOM.$parse("        <li>\n          <span class=\"group_description\">\n            " + group.$description() + "\n          </span>\n        </li>\n      ");
        this.example_list = __scope.DOM.$parse("        <ul class=\"examples\"></ul>\n      ");
        this.group_element.$lshft$(this.example_list);
        return this.groups_element.$lshft$(this.group_element);
      };

      // line 93, lib/opal/spec/browser_formatter.rb, BrowserFormatter#example_group_finished
      BrowserFormatter_prototype.$example_group_finished = function(group) {
        var __a;
        if ((__a = this.example_group_failed) !== false && __a !== nil) {
          return this.group_element.$class_name$e("group failed")
          } else {
          return this.group_element.$class_name$e("group passed")
        };
      };

      // line 101, lib/opal/spec/browser_formatter.rb, BrowserFormatter#example_started
      BrowserFormatter_prototype.$example_started = function(example) {
        
        this.examples.$lshft$(example);
        return this.example = example;
      };

      // line 106, lib/opal/spec/browser_formatter.rb, BrowserFormatter#example_failed
      BrowserFormatter_prototype.$example_failed = function(example) {
        var exception = nil, $case = nil, output = nil, wrapper = nil, description = nil;
        this.failed_examples.$lshft$(example);
        this.example_group_failed = true;
        exception = example.$exception();
        $case = exception;if ((__scope.Spec)._scope.ExpectationNotMetError.$eqq$($case)) {
        output = exception.$message()
        }
        else {output = "" + exception.$class() + ": " + exception.$message() + "\n";
        output = output.$plus$("    " + exception.$backtrace().$join("\n    ") + "\n");};
        wrapper = __scope.DOM.$parse("<li class=\"example failed\"></li>");
        description = __scope.DOM.$parse("        <span class=\"example_description\">" + example.$description() + "</span>\n      ");
        exception = __scope.DOM.$parse("        <pre class=\"exception\">" + output + "</pre>\n      ");
        wrapper.$lshft$(description);
        wrapper.$lshft$(exception);
        this.example_list.$append(wrapper);
        return this.example_list.$css("display", "list-item");
      };

      // line 138, lib/opal/spec/browser_formatter.rb, BrowserFormatter#example_passed
      BrowserFormatter_prototype.$example_passed = function(example) {
        var out = nil;
        out = __scope.DOM.$parse("        <li class=\"example passed\">\n          <span class=\"example_description\">" + example.$description() + "</span>\n        </li>\n      ");
        return this.example_list.$append(out);
      };

      // line 147, lib/opal/spec/browser_formatter.rb, BrowserFormatter#example_count
      BrowserFormatter_prototype.$example_count = function() {
        
        return this.examples.$size();
      };
      ;BrowserFormatter._donate(["$initialize", "$start", "$finish", "$example_group_started", "$example_group_finished", "$example_started", "$example_failed", "$example_passed", "$example_count"]);
    })(Spec, null)
    
  })(self)
})();
// file lib/opal/spec/example.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;

  return (function(__base){
    // line 1, lib/opal/spec/example.rb, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, lib/opal/spec/example.rb, class Example
      function Example() {};
      Example = __klass(__base, __super, "Example", Example);
      var Example_prototype = Example.prototype, __scope = Example._scope;
      Example_prototype.description = Example_prototype.example_group = Example_prototype.exception = Example_prototype.__block__ = nil;

      // line 3, lib/opal/spec/example.rb, Example#description
      Example_prototype.$description = function() {
        
        return this.description
      }, 
      // line 3, lib/opal/spec/example.rb, Example#example_group
      Example_prototype.$example_group = function() {
        
        return this.example_group
      }, 
      // line 3, lib/opal/spec/example.rb, Example#exception
      Example_prototype.$exception = function() {
        
        return this.exception
      };

      // line 5, lib/opal/spec/example.rb, Example#initialize
      Example_prototype.$initialize = function(group, desc, block) {
        
        this.example_group = group;
        this.description = desc;
        return this.__block__ = block;
      };

      // line 11, lib/opal/spec/example.rb, Example#run_before_hooks
      Example_prototype.$run_before_hooks = function() {
        var __a, __b;
        return (__b = this.example_group.$before_hooks(), __b.$each._p = (__a = function(before) {

          var __a;
          if (before == null) before = nil;

          return (__a = this, __a.$instance_eval._p = before.$to_proc(), __a.$instance_eval())
        }, __a._s = this, __a), __b.$each());
      };

      // line 17, lib/opal/spec/example.rb, Example#run_after_hooks
      Example_prototype.$run_after_hooks = function() {
        var __a, __b;
        return (__b = this.example_group.$after_hooks(), __b.$each._p = (__a = function(after) {

          var __a;
          if (after == null) after = nil;

          return (__a = this, __a.$instance_eval._p = after.$to_proc(), __a.$instance_eval())
        }, __a._s = this, __a), __b.$each());
      };

      // line 23, lib/opal/spec/example.rb, Example#run
      Example_prototype.$run = function(runner) {
        var e = nil, __a;
        try {
        runner.$example_started(this);
        this.$run_before_hooks();
        (__a = this, __a.$instance_eval._p = this.__block__.$to_proc(), __a.$instance_eval());
        } catch ($err) {
        if (true) {
        e = $err;this.exception = e}
        else { throw $err; }
        }
        finally {
        try {
        this.$run_after_hooks()
        } catch ($err) {
        if (true) {
        e = $err;this.exception = e}
        else { throw $err; }
        }};
        if ((__a = this.exception) !== false && __a !== nil) {
          return runner.$example_failed(this)
          } else {
          return runner.$example_passed(this)
        };
      };
      ;Example._donate(["$description", "$example_group", "$exception", "$initialize", "$run_before_hooks", "$run_after_hooks", "$run"]);
    })(Spec, null)
    
  })(self)
})();
// file lib/opal/spec/example_group.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;

  return (function(__base){
    // line 1, lib/opal/spec/example_group.rb, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, lib/opal/spec/example_group.rb, class ExampleGroup
      function ExampleGroup() {};
      ExampleGroup = __klass(__base, __super, "ExampleGroup", ExampleGroup);
      var ExampleGroup_prototype = ExampleGroup.prototype, __scope = ExampleGroup._scope, TMP_1, TMP_2, TMP_3;
      ExampleGroup_prototype.example_groups = ExampleGroup_prototype.stack = ExampleGroup_prototype.examples = ExampleGroup_prototype.before_hooks = ExampleGroup_prototype.after_hooks = ExampleGroup_prototype.parent = ExampleGroup_prototype.desc = nil;

      ExampleGroup.example_groups = [];

      // line 4, lib/opal/spec/example_group.rb, ExampleGroup.example_groups
      ExampleGroup.$example_groups = function() {
        
        return this.example_groups
      };

      ExampleGroup.stack = [];

      // line 9, lib/opal/spec/example_group.rb, ExampleGroup.create
      ExampleGroup.$create = function(desc, block) {
        var group = nil, __a;
        group = this.$new(desc, this.stack.$last());
        this.example_groups.$lshft$(group);
        this.stack.$lshft$(group);
        (__a = group, __a.$instance_eval._p = block.$to_proc(), __a.$instance_eval());
        return this.stack.$pop();
      };

      // line 18, lib/opal/spec/example_group.rb, ExampleGroup#initialize
      ExampleGroup_prototype.$initialize = function(desc, parent) {
        
        this.desc = desc.$to_s();
        this.parent = parent;
        this.examples = [];
        this.before_hooks = [];
        return this.after_hooks = [];
      };

      // line 27, lib/opal/spec/example_group.rb, ExampleGroup#it
      ExampleGroup_prototype.$it = TMP_1 = function(desc) {
        var __context, block;
        block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
        
        return this.examples.$lshft$(__scope.Example.$new(this, desc, block));
      };

      // line 31, lib/opal/spec/example_group.rb, ExampleGroup#it_behaves_like
      ExampleGroup_prototype.$it_behaves_like = function(objs) {
        objs = __slice.call(arguments, 0);
        return nil;
      };

      // line 34, lib/opal/spec/example_group.rb, ExampleGroup#before
      ExampleGroup_prototype.$before = TMP_2 = function(type) {
        var __a, __context, block;
        block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
        if (type == null) {
          type = "each"
        }
        if ((__a = type.$eq$("each")) === false || __a === nil) {
          this.$raise("unsupported before type: " + type)
        };
        return this.before_hooks.$lshft$(block);
      };

      // line 39, lib/opal/spec/example_group.rb, ExampleGroup#after
      ExampleGroup_prototype.$after = TMP_3 = function(type) {
        var __a, __context, block;
        block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
        if (type == null) {
          type = "each"
        }
        if ((__a = type.$eq$("each")) === false || __a === nil) {
          this.$raise("unsupported after type: " + type)
        };
        return this.after_hooks.$lshft$(block);
      };

      // line 44, lib/opal/spec/example_group.rb, ExampleGroup#before_hooks
      ExampleGroup_prototype.$before_hooks = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return [].$concat(this.parent.$before_hooks()).$concat(this.before_hooks)
          } else {
          return this.before_hooks
        };
      };

      // line 48, lib/opal/spec/example_group.rb, ExampleGroup#after_hooks
      ExampleGroup_prototype.$after_hooks = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return [].$concat(this.parent.$after_hooks()).$concat(this.after_hooks)
          } else {
          return this.after_hooks
        };
      };

      // line 52, lib/opal/spec/example_group.rb, ExampleGroup#run
      ExampleGroup_prototype.$run = function(runner) {
        var __a, __b;
        runner.$example_group_started(this);
        (__b = this.examples, __b.$each._p = (__a = function(example) {

          
          if (example == null) example = nil;

          return example.$run(runner)
        }, __a._s = this, __a), __b.$each());
        return runner.$example_group_finished(this);
      };

      // line 58, lib/opal/spec/example_group.rb, ExampleGroup#description
      ExampleGroup_prototype.$description = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return "" + this.parent.$description() + " " + this.desc
          } else {
          return this.desc
        };
      };
      ;ExampleGroup._donate(["$initialize", "$it", "$it_behaves_like", "$before", "$after", "$before_hooks", "$after_hooks", "$run", "$description"]);      ;ExampleGroup._sdonate(["$example_groups", "$create"]);
    })(Spec, null)
    
  })(self)
})();
// file lib/opal/spec/expectations.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;

  (function(__base){
    // line 1, lib/opal/spec/expectations.rb, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, lib/opal/spec/expectations.rb, class ExpectationNotMetError
      function ExpectationNotMetError() {};
      ExpectationNotMetError = __klass(__base, __super, "ExpectationNotMetError", ExpectationNotMetError);
      var ExpectationNotMetError_prototype = ExpectationNotMetError.prototype, __scope = ExpectationNotMetError._scope;

      nil

    })(Spec, __scope.StandardError);

    (function(__base){
      // line 4, lib/opal/spec/expectations.rb, module Expectations
      function Expectations() {};
      Expectations = __module(__base, "Expectations", Expectations);
      var Expectations_prototype = Expectations.prototype, __scope = Expectations._scope;

      // line 5, lib/opal/spec/expectations.rb, Expectations#should
      Expectations_prototype.$should = function(matcher) {
        if (matcher == null) {
          matcher = nil
        }
        if (matcher !== false && matcher !== nil) {
          return matcher.$match(this)
          } else {
          return (__scope.Spec)._scope.PositiveOperatorMatcher.$new(this)
        };
      };

      // line 13, lib/opal/spec/expectations.rb, Expectations#should_not
      Expectations_prototype.$should_not = function(matcher) {
        if (matcher == null) {
          matcher = nil
        }
        if (matcher !== false && matcher !== nil) {
          return matcher.$not_match(this)
          } else {
          return (__scope.Spec)._scope.NegativeOperatorMatcher.$new(this)
        };
      };

      // line 21, lib/opal/spec/expectations.rb, Expectations#be_kind_of
      Expectations_prototype.$be_kind_of = function(expected) {
        
        return (__scope.Spec)._scope.BeKindOfMatcher.$new(expected);
      };

      // line 25, lib/opal/spec/expectations.rb, Expectations#be_nil
      Expectations_prototype.$be_nil = function() {
        
        return (__scope.Spec)._scope.BeNilMatcher.$new(nil);
      };

      // line 29, lib/opal/spec/expectations.rb, Expectations#be_true
      Expectations_prototype.$be_true = function() {
        
        return (__scope.Spec)._scope.BeTrueMatcher.$new(true);
      };

      // line 33, lib/opal/spec/expectations.rb, Expectations#be_false
      Expectations_prototype.$be_false = function() {
        
        return (__scope.Spec)._scope.BeFalseMatcher.$new(false);
      };

      // line 37, lib/opal/spec/expectations.rb, Expectations#equal
      Expectations_prototype.$equal = function(expected) {
        
        return (__scope.Spec)._scope.EqualMatcher.$new(expected);
      };

      // line 41, lib/opal/spec/expectations.rb, Expectations#raise_error
      Expectations_prototype.$raise_error = function(expected) {
        
        return (__scope.Spec)._scope.RaiseErrorMatcher.$new(expected);
      };
            ;Expectations._donate(["$should", "$should_not", "$be_kind_of", "$be_nil", "$be_true", "$be_false", "$equal", "$raise_error"]);
    })(Spec);
    
  })(self);
  return (function(__base, __super){
    // line 47, lib/opal/spec/expectations.rb, class Object
    function Object() {};
    Object = __klass(__base, __super, "Object", Object);
    var Object_prototype = Object.prototype, __scope = Object._scope;

    Object.$include((__scope.Spec)._scope.Expectations)

  })(self, null);
})();
// file lib/opal/spec/kernel.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;

  return (function(__base){
    // line 1, lib/opal/spec/kernel.rb, module Kernel
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope, TMP_1;

    // line 2, lib/opal/spec/kernel.rb, Kernel#describe
    Kernel_prototype.$describe = TMP_1 = function(desc) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      return (__scope.Spec)._scope.ExampleGroup.$create(desc, block);
    };

    // line 6, lib/opal/spec/kernel.rb, Kernel#mock
    Kernel_prototype.$mock = function(obj) {
      
      return __scope.Object.$new();
    };
        ;Kernel._donate(["$describe", "$mock"]);
  })(self)
})();
// file lib/opal/spec/matchers.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;

  return (function(__base){
    // line 1, lib/opal/spec/matchers.rb, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, lib/opal/spec/matchers.rb, class Matcher
      function Matcher() {};
      Matcher = __klass(__base, __super, "Matcher", Matcher);
      var Matcher_prototype = Matcher.prototype, __scope = Matcher._scope;

      // line 3, lib/opal/spec/matchers.rb, Matcher#initialize
      Matcher_prototype.$initialize = function(actual) {
        
        return this.actual = actual;
      };

      // line 7, lib/opal/spec/matchers.rb, Matcher#failure
      Matcher_prototype.$failure = function(message) {
        
        return this.$raise((__scope.Spec)._scope.ExpectationNotMetError, message);
      };
      ;Matcher._donate(["$initialize", "$failure"]);
    })(Spec, null);

    (function(__base, __super){
      // line 12, lib/opal/spec/matchers.rb, class PositiveOperatorMatcher
      function PositiveOperatorMatcher() {};
      PositiveOperatorMatcher = __klass(__base, __super, "PositiveOperatorMatcher", PositiveOperatorMatcher);
      var PositiveOperatorMatcher_prototype = PositiveOperatorMatcher.prototype, __scope = PositiveOperatorMatcher._scope;
      PositiveOperatorMatcher_prototype.actual = nil;

      // line 13, lib/opal/spec/matchers.rb, PositiveOperatorMatcher#==
      PositiveOperatorMatcher_prototype.$eq$ = function(expected) {
        
        if (this.actual.$eq$(expected)) {
          return true
          } else {
          return this.$failure("expected: " + expected.$inspect() + ", got: " + this.actual.$inspect() + " (using ==).")
        };
      }
      ;PositiveOperatorMatcher._donate(["$eq$"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 22, lib/opal/spec/matchers.rb, class NegativeOperatorMatcher
      function NegativeOperatorMatcher() {};
      NegativeOperatorMatcher = __klass(__base, __super, "NegativeOperatorMatcher", NegativeOperatorMatcher);
      var NegativeOperatorMatcher_prototype = NegativeOperatorMatcher.prototype, __scope = NegativeOperatorMatcher._scope;
      NegativeOperatorMatcher_prototype.actual = nil;

      // line 23, lib/opal/spec/matchers.rb, NegativeOperatorMatcher#==
      NegativeOperatorMatcher_prototype.$eq$ = function(expected) {
        
        if (this.actual.$eq$(expected)) {
          return this.$failure("expected: " + expected.$inspect() + " not to be " + this.actual.$inspect() + " (using ==).")
          } else {
          return nil
        };
      }
      ;NegativeOperatorMatcher._donate(["$eq$"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 30, lib/opal/spec/matchers.rb, class BeKindOfMatcher
      function BeKindOfMatcher() {};
      BeKindOfMatcher = __klass(__base, __super, "BeKindOfMatcher", BeKindOfMatcher);
      var BeKindOfMatcher_prototype = BeKindOfMatcher.prototype, __scope = BeKindOfMatcher._scope;
      BeKindOfMatcher_prototype.actual = nil;

      // line 31, lib/opal/spec/matchers.rb, BeKindOfMatcher#match
      BeKindOfMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected.$kind_of$p(this.actual)) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + expected.$inspect() + " to be a kind of " + this.actual + ", not " + expected.$class() + ".")
        };
      }
      ;BeKindOfMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 38, lib/opal/spec/matchers.rb, class BeNilMatcher
      function BeNilMatcher() {};
      BeNilMatcher = __klass(__base, __super, "BeNilMatcher", BeNilMatcher);
      var BeNilMatcher_prototype = BeNilMatcher.prototype, __scope = BeNilMatcher._scope;

      // line 39, lib/opal/spec/matchers.rb, BeNilMatcher#match
      BeNilMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected.$nil$p()) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + expected.$inspect() + " to be nil.")
        };
      }
      ;BeNilMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 46, lib/opal/spec/matchers.rb, class BeTrueMatcher
      function BeTrueMatcher() {};
      BeTrueMatcher = __klass(__base, __super, "BeTrueMatcher", BeTrueMatcher);
      var BeTrueMatcher_prototype = BeTrueMatcher.prototype, __scope = BeTrueMatcher._scope;

      // line 47, lib/opal/spec/matchers.rb, BeTrueMatcher#match
      BeTrueMatcher_prototype.$match = function(expected) {
        
        if (expected.$eq$(true)) {
          return nil
          } else {
          return this.$failure("expected " + expected.$inspect() + " to be true.")
        };
      }
      ;BeTrueMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 54, lib/opal/spec/matchers.rb, class BeFalseMatcher
      function BeFalseMatcher() {};
      BeFalseMatcher = __klass(__base, __super, "BeFalseMatcher", BeFalseMatcher);
      var BeFalseMatcher_prototype = BeFalseMatcher.prototype, __scope = BeFalseMatcher._scope;

      // line 55, lib/opal/spec/matchers.rb, BeFalseMatcher#match
      BeFalseMatcher_prototype.$match = function(expected) {
        
        if (expected.$eq$(false)) {
          return nil
          } else {
          return this.$failure("expected " + expected.$inspect() + " to be false.")
        };
      }
      ;BeFalseMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 62, lib/opal/spec/matchers.rb, class EqualMatcher
      function EqualMatcher() {};
      EqualMatcher = __klass(__base, __super, "EqualMatcher", EqualMatcher);
      var EqualMatcher_prototype = EqualMatcher.prototype, __scope = EqualMatcher._scope;
      EqualMatcher_prototype.actual = nil;

      // line 63, lib/opal/spec/matchers.rb, EqualMatcher#match
      EqualMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected.$equal$p(this.actual)) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + this.actual.$inspect() + " to be the same as " + expected.$inspect() + ".")
        };
      };

      // line 69, lib/opal/spec/matchers.rb, EqualMatcher#not_match
      EqualMatcher_prototype.$not_match = function(expected) {
        var __a;
        if ((__a = expected.$equal$p(this.actual)) !== false && __a !== nil) {
          return this.$failure("expected " + this.actual.$inspect() + " not to be equal to " + expected.$inspect() + ".")
          } else {
          return nil
        };
      };
      ;EqualMatcher._donate(["$match", "$not_match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 76, lib/opal/spec/matchers.rb, class RaiseErrorMatcher
      function RaiseErrorMatcher() {};
      RaiseErrorMatcher = __klass(__base, __super, "RaiseErrorMatcher", RaiseErrorMatcher);
      var RaiseErrorMatcher_prototype = RaiseErrorMatcher.prototype, __scope = RaiseErrorMatcher._scope;
      RaiseErrorMatcher_prototype.actual = nil;

      // line 77, lib/opal/spec/matchers.rb, RaiseErrorMatcher#match
      RaiseErrorMatcher_prototype.$match = function(block) {
        var should_raise = nil, e = nil;
        should_raise = false;
        try {
        block.$call();
        should_raise = true;
        } catch ($err) {
        if (true) {
        e = $err;nil}
        else { throw $err; }
        };
        if (should_raise !== false && should_raise !== nil) {
          return this.$failure("expected " + this.actual + " to be raised, but nothing was.")
          } else {
          return nil
        };
      }
      ;RaiseErrorMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);
    
  })(self)
})();
// file lib/opal/spec/runner.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;

  return (function(__base){
    // line 1, lib/opal/spec/runner.rb, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, lib/opal/spec/runner.rb, class Runner
      function Runner() {};
      Runner = __klass(__base, __super, "Runner", Runner);
      var Runner_prototype = Runner.prototype, __scope = Runner._scope;
      Runner_prototype.formatter = nil;

      // line 3, lib/opal/spec/runner.rb, Runner#initialize
      Runner_prototype.$initialize = function() {
        
        return this.formatter = __scope.BrowserFormatter.$new();
      };

      // line 7, lib/opal/spec/runner.rb, Runner#run
      Runner_prototype.$run = function() {
        var groups = nil, __a, __b;
        groups = __scope.ExampleGroup.$example_groups();
        this.formatter.$start();
        (__b = groups, __b.$each._p = (__a = function(group) {

          
          if (group == null) group = nil;

          return group.$run(this)
        }, __a._s = this, __a), __b.$each());
        return this.formatter.$finish();
      };

      // line 14, lib/opal/spec/runner.rb, Runner#example_group_started
      Runner_prototype.$example_group_started = function(group) {
        
        return this.formatter.$example_group_started(group);
      };

      // line 18, lib/opal/spec/runner.rb, Runner#example_group_finished
      Runner_prototype.$example_group_finished = function(group) {
        
        return this.formatter.$example_group_finished(group);
      };

      // line 22, lib/opal/spec/runner.rb, Runner#example_started
      Runner_prototype.$example_started = function(example) {
        
        return this.formatter.$example_started(example);
      };

      // line 26, lib/opal/spec/runner.rb, Runner#example_passed
      Runner_prototype.$example_passed = function(example) {
        
        return this.formatter.$example_passed(example);
      };

      // line 30, lib/opal/spec/runner.rb, Runner#example_failed
      Runner_prototype.$example_failed = function(example) {
        
        return this.formatter.$example_failed(example);
      };
      ;Runner._donate(["$initialize", "$run", "$example_group_started", "$example_group_finished", "$example_started", "$example_passed", "$example_failed"]);
    })(Spec, null)
    
  })(self)
})();
// file lib/opal/spec/scratch_pad.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;

  return (function(__base){
    // line 1, lib/opal/spec/scratch_pad.rb, module ScratchPad
    function ScratchPad() {};
    ScratchPad = __module(__base, "ScratchPad", ScratchPad);
    var ScratchPad_prototype = ScratchPad.prototype, __scope = ScratchPad._scope;

    // line 2, lib/opal/spec/scratch_pad.rb, ScratchPad.clear
    ScratchPad.$clear = function() {
      
      return this.record = nil
    };

    // line 6, lib/opal/spec/scratch_pad.rb, ScratchPad.record
    ScratchPad.$record = function(arg) {
      
      return this.record = arg
    };

    // line 10, lib/opal/spec/scratch_pad.rb, ScratchPad.<<
    ScratchPad.$lshft$ = function(arg) {
      
      if (this.record == null) this.record = nil;

      return this.record.$lshft$(arg)
    };

    // line 14, lib/opal/spec/scratch_pad.rb, ScratchPad.recorded
    ScratchPad.$recorded = function() {
      
      if (this.record == null) this.record = nil;

      return this.record
    };
        ;ScratchPad._sdonate(["$clear", "$record", "$lshft$", "$recorded"]);
  })(self)
})();
// file lib/opal/spec/version.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;

  return (function(__base){
    // line 1, lib/opal/spec/version.rb, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    __scope.VERSION = "0.1.9"
    
  })(self)
})();
// file lib/opal/spec.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice;

  nil;
  nil;
  nil;
  nil;
  nil;
  nil;
  nil;
  nil;
  return nil;
})();
