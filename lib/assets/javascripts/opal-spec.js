// lib/opal-spec/browser_formatter.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    // line 1, opal-spec/browser_formatter, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/browser_formatter, class BrowserFormatter
      function BrowserFormatter() {};
      BrowserFormatter = __klass(__base, __super, "BrowserFormatter", BrowserFormatter);
      var BrowserFormatter_prototype = BrowserFormatter.prototype, __scope = BrowserFormatter._scope;
      BrowserFormatter_prototype.start_time = BrowserFormatter_prototype.failed_examples = BrowserFormatter_prototype.summary_element = BrowserFormatter_prototype.groups_element = BrowserFormatter_prototype.example_group_failed = BrowserFormatter_prototype.group_element = BrowserFormatter_prototype.examples = BrowserFormatter_prototype.example_list = nil;

      __scope.CSS = "\n      body {\n        font-size: 14px;\n        font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\n      }\n\n      pre {\n        font-family: \"Bitstream Vera Sans Mono\", Monaco, \"Lucida Console\", monospace;\n        font-size: 12px;\n        color: #444444;\n        white-space: pre;\n        padding: 3px 0px 3px 12px;\n        margin: 0px 0px 8px;\n\n        background: #FAFAFA;\n        -webkit-box-shadow: rgba(0,0,0,0.07) 0 1px 2px inset;\n        -webkit-border-radius: 3px;\n        -moz-border-radius: 3px;\n        border-radius: 3px;\n        border: 1px solid #DDDDDD;\n      }\n\n      ul.example_groups {\n        list-style-type: none;\n      }\n\n      li.group.passed .group_description {\n        color: #597800;\n        font-weight: bold;\n      }\n\n      li.group.failed .group_description {\n        color: #FF000E;\n        font-weight: bold;\n      }\n\n      li.example.passed {\n        color: #597800;\n      }\n\n      li.example.failed {\n        color: #FF000E;\n      }\n\n      .examples {\n        list-style-type: none;\n      }\n    ";

      // line 52, opal-spec/browser_formatter, BrowserFormatter#initialize
      BrowserFormatter_prototype.$initialize = function() {
        
        this.examples = [];
        return this.failed_examples = [];
      };

      // line 57, opal-spec/browser_formatter, BrowserFormatter#start
      BrowserFormatter_prototype.$start = function() {
        
        
        if (!document || !document.body) {
          this.$raise("Not running in browser.");
        }

        var summary_element = document.createElement('p');
        summary_element.className = 'summary';

        var groups_element = document.createElement('ul');
        groups_element.className = 'example_groups';

        var target = document.getElementById('opal-spec-output');

        if (!target) {
          target = document.body;
        }

        target.appendChild(summary_element);
        target.appendChild(groups_element);

        var styles = document.createElement('style');
        styles.innerHTML = __scope.CSS;
        document.head.appendChild(styles);
      
        this.start_time = __scope.Time.$now().$to_f();
        this.groups_element = groups_element;
        return this.summary_element = summary_element;
      };

      // line 88, opal-spec/browser_formatter, BrowserFormatter#finish
      BrowserFormatter_prototype.$finish = function() {
        var time = nil, text = nil, __a, __b;
        time = (__a = __scope.Time.$now().$to_f(), __b = this.start_time, typeof(__a) === 'number' ? __a - __b : __a['$-'](__b));
        text = "\n" + (this.$example_count()) + " examples, " + (this.failed_examples.$size()) + " failures (time taken: " + (time) + ")";
        return this.summary_element.innerHTML = text;
      };

      // line 95, opal-spec/browser_formatter, BrowserFormatter#example_group_started
      BrowserFormatter_prototype.$example_group_started = function(group) {
        
        this.example_group = group;
        this.example_group_failed = false;
        
        var group_element = document.createElement('li');

        var description = document.createElement('span');
        description.className = 'group_description';
        description.innerHTML = group.$description();
        group_element.appendChild(description);

        var example_list = document.createElement('ul');
        example_list.className = 'examples';
        group_element.appendChild(example_list);

        this.groups_element.appendChild(group_element);
      
        this.group_element = group_element;
        return this.example_list = example_list;
      };

      // line 118, opal-spec/browser_formatter, BrowserFormatter#example_group_finished
      BrowserFormatter_prototype.$example_group_finished = function(group) {
        var __a;
        if ((__a = this.example_group_failed) !== false && __a !== nil) {
          return this.group_element.className = 'group failed';
          } else {
          return this.group_element.className = 'group passed';
        };
      };

      // line 126, opal-spec/browser_formatter, BrowserFormatter#example_started
      BrowserFormatter_prototype.$example_started = function(example) {
        
        this.examples['$<<'](example);
        return this.example = example;
      };

      // line 131, opal-spec/browser_formatter, BrowserFormatter#example_failed
      BrowserFormatter_prototype.$example_failed = function(example) {
        var exception = nil, $case = nil, output = nil;
        this.failed_examples['$<<'](example);
        this.example_group_failed = true;
        exception = example.$exception();
        $case = exception;if ((__scope.Spec)._scope.ExpectationNotMetError['$===']($case)) {
        output = exception.$message()
        }
        else {output = "" + (exception['$class']()) + ": " + (exception.$message()) + "\n";
        output = output['$+']("    " + (exception.$backtrace().$join("\n    ")) + "\n");};
        
        var wrapper = document.createElement('li');
        wrapper.className = 'example failed';

        var description = document.createElement('span');
        description.className = 'example_description';
        description.innerHTML = example.$description();

        var exception = document.createElement('pre');
        exception.className = 'exception';
        exception.innerHTML = output;

        wrapper.appendChild(description);
        wrapper.appendChild(exception);

        this.example_list.appendChild(wrapper);
        this.example_list.style.display = 'list-item';
      
      };

      // line 168, opal-spec/browser_formatter, BrowserFormatter#example_passed
      BrowserFormatter_prototype.$example_passed = function(example) {
        
        
        var wrapper = document.createElement('li');
        wrapper.className = 'example passed';

        var description = document.createElement('span');
        description.className = 'example_description';
        description.innerHTML = example.$description();

        wrapper.appendChild(description);
        this.example_list.appendChild(wrapper);
      
      };

      // line 182, opal-spec/browser_formatter, BrowserFormatter#example_count
      BrowserFormatter_prototype.$example_count = function() {
        
        return this.examples.$size();
      };
      ;BrowserFormatter._donate(["$initialize", "$start", "$finish", "$example_group_started", "$example_group_finished", "$example_started", "$example_failed", "$example_passed", "$example_count"]);
    })(Spec, null)
    
  })(self)
})();
// lib/opal-spec/example.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    // line 1, opal-spec/example, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/example, class Example
      function Example() {};
      Example = __klass(__base, __super, "Example", Example);
      var Example_prototype = Example.prototype, __scope = Example._scope;
      Example_prototype.description = Example_prototype.example_group = Example_prototype.exception = Example_prototype.__block__ = nil;

      // line 3, opal-spec/example, Example#description
      Example_prototype.$description = function() {
        
        return this.description
      }, 
      // line 3, opal-spec/example, Example#example_group
      Example_prototype.$example_group = function() {
        
        return this.example_group
      }, 
      // line 3, opal-spec/example, Example#exception
      Example_prototype.$exception = function() {
        
        return this.exception
      };

      // line 5, opal-spec/example, Example#initialize
      Example_prototype.$initialize = function(group, desc, block) {
        
        this.example_group = group;
        this.description = desc;
        return this.__block__ = block;
      };

      // line 11, opal-spec/example, Example#run_before_hooks
      Example_prototype.$run_before_hooks = function() {
        var __a, __b;
        return (__b = this.example_group.$before_hooks(), __b.$each._p = (__a = function(before) {

          var __a;
          if (before == null) before = nil;

          return (__a = this, __a.$instance_eval._p = before.$to_proc(), __a.$instance_eval())
        }, __a._s = this, __a), __b.$each());
      };

      // line 17, opal-spec/example, Example#run_after_hooks
      Example_prototype.$run_after_hooks = function() {
        var __a, __b;
        return (__b = this.example_group.$after_hooks(), __b.$each._p = (__a = function(after) {

          var __a;
          if (after == null) after = nil;

          return (__a = this, __a.$instance_eval._p = after.$to_proc(), __a.$instance_eval())
        }, __a._s = this, __a), __b.$each());
      };

      // line 23, opal-spec/example, Example#run
      Example_prototype.$run = function(runner) {
        var e = nil, __a, __b;
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
        if ((__b = this.exception) !== false && __b !== nil) {
          return runner.$example_failed(this)
          } else {
          return runner.$example_passed(this)
        };
      };
      ;Example._donate(["$description", "$example_group", "$exception", "$initialize", "$run_before_hooks", "$run_after_hooks", "$run"]);
    })(Spec, null)
    
  })(self)
})();
// lib/opal-spec/example_group.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    // line 1, opal-spec/example_group, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/example_group, class ExampleGroup
      function ExampleGroup() {};
      ExampleGroup = __klass(__base, __super, "ExampleGroup", ExampleGroup);
      var ExampleGroup_prototype = ExampleGroup.prototype, __scope = ExampleGroup._scope, TMP_1, TMP_2, TMP_3;
      ExampleGroup_prototype.examples = ExampleGroup_prototype.before_hooks = ExampleGroup_prototype.after_hooks = ExampleGroup_prototype.parent = ExampleGroup_prototype.desc = nil;

      ExampleGroup.example_groups = [];

      // line 4, opal-spec/example_group, ExampleGroup.example_groups
      ExampleGroup.$example_groups = function() {
        
        if (this.example_groups == null) this.example_groups = nil;

        return this.example_groups
      };

      ExampleGroup.stack = [];

      // line 9, opal-spec/example_group, ExampleGroup.create
      ExampleGroup.$create = function(desc, block) {
        var group = nil, __a;
        if (this.stack == null) this.stack = nil;
        if (this.example_groups == null) this.example_groups = nil;

        group = this['$new'](desc, this.stack.$last());
        this.example_groups['$<<'](group);
        this.stack['$<<'](group);
        (__a = group, __a.$instance_eval._p = block.$to_proc(), __a.$instance_eval());
        return this.stack.$pop();
      };

      // line 18, opal-spec/example_group, ExampleGroup#initialize
      ExampleGroup_prototype.$initialize = function(desc, parent) {
        
        this.desc = desc.$to_s();
        this.parent = parent;
        this.examples = [];
        this.before_hooks = [];
        return this.after_hooks = [];
      };

      // line 27, opal-spec/example_group, ExampleGroup#it
      ExampleGroup_prototype.$it = TMP_1 = function(desc) {
        var __context, block;
        block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
        
        return this.examples['$<<'](__scope.Example['$new'](this, desc, block));
      };

      // line 31, opal-spec/example_group, ExampleGroup#it_behaves_like
      ExampleGroup_prototype.$it_behaves_like = function(objs) {
        objs = __slice.call(arguments, 0);
        return nil;
      };

      // line 34, opal-spec/example_group, ExampleGroup#before
      ExampleGroup_prototype.$before = TMP_2 = function(type) {
        var __a, __context, block;
        block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
        if (type == null) {
          type = "each"
        }
        if ((__a = type['$==']("each")) === false || __a === nil) {
          this.$raise("unsupported before type: " + (type))
        };
        return this.before_hooks['$<<'](block);
      };

      // line 39, opal-spec/example_group, ExampleGroup#after
      ExampleGroup_prototype.$after = TMP_3 = function(type) {
        var __a, __context, block;
        block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
        if (type == null) {
          type = "each"
        }
        if ((__a = type['$==']("each")) === false || __a === nil) {
          this.$raise("unsupported after type: " + (type))
        };
        return this.after_hooks['$<<'](block);
      };

      // line 44, opal-spec/example_group, ExampleGroup#before_hooks
      ExampleGroup_prototype.$before_hooks = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return [].$concat(this.parent.$before_hooks()).$concat(this.before_hooks)
          } else {
          return this.before_hooks
        };
      };

      // line 48, opal-spec/example_group, ExampleGroup#after_hooks
      ExampleGroup_prototype.$after_hooks = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return [].$concat(this.parent.$after_hooks()).$concat(this.after_hooks)
          } else {
          return this.after_hooks
        };
      };

      // line 52, opal-spec/example_group, ExampleGroup#run
      ExampleGroup_prototype.$run = function(runner) {
        var __a, __b;
        runner.$example_group_started(this);
        (__b = this.examples, __b.$each._p = (__a = function(example) {

          
          if (example == null) example = nil;

          return example.$run(runner)
        }, __a._s = this, __a), __b.$each());
        return runner.$example_group_finished(this);
      };

      // line 58, opal-spec/example_group, ExampleGroup#description
      ExampleGroup_prototype.$description = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return "" + (this.parent.$description()) + " " + (this.desc)
          } else {
          return this.desc
        };
      };
      ;ExampleGroup._donate(["$initialize", "$it", "$it_behaves_like", "$before", "$after", "$before_hooks", "$after_hooks", "$run", "$description"]);      ;ExampleGroup._sdonate(["$example_groups", "$create"]);
    })(Spec, null)
    
  })(self)
})();
// lib/opal-spec/expectations.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  (function(__base){
    // line 1, opal-spec/expectations, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/expectations, class ExpectationNotMetError
      function ExpectationNotMetError() {};
      ExpectationNotMetError = __klass(__base, __super, "ExpectationNotMetError", ExpectationNotMetError);
      var ExpectationNotMetError_prototype = ExpectationNotMetError.prototype, __scope = ExpectationNotMetError._scope;

      nil

    })(Spec, __scope.StandardError);

    (function(__base){
      // line 4, opal-spec/expectations, module Expectations
      function Expectations() {};
      Expectations = __module(__base, "Expectations", Expectations);
      var Expectations_prototype = Expectations.prototype, __scope = Expectations._scope;

      // line 5, opal-spec/expectations, Expectations#should
      Expectations_prototype.$should = function(matcher) {
        if (matcher == null) {
          matcher = nil
        }
        if (matcher !== false && matcher !== nil) {
          return matcher.$match(this)
          } else {
          return (__scope.Spec)._scope.PositiveOperatorMatcher['$new'](this)
        };
      };

      // line 13, opal-spec/expectations, Expectations#should_not
      Expectations_prototype.$should_not = function(matcher) {
        if (matcher == null) {
          matcher = nil
        }
        if (matcher !== false && matcher !== nil) {
          return matcher.$not_match(this)
          } else {
          return (__scope.Spec)._scope.NegativeOperatorMatcher['$new'](this)
        };
      };

      // line 21, opal-spec/expectations, Expectations#be_kind_of
      Expectations_prototype.$be_kind_of = function(expected) {
        
        return (__scope.Spec)._scope.BeKindOfMatcher['$new'](expected);
      };

      // line 25, opal-spec/expectations, Expectations#be_nil
      Expectations_prototype.$be_nil = function() {
        
        return (__scope.Spec)._scope.BeNilMatcher['$new'](nil);
      };

      // line 29, opal-spec/expectations, Expectations#be_true
      Expectations_prototype.$be_true = function() {
        
        return (__scope.Spec)._scope.BeTrueMatcher['$new'](true);
      };

      // line 33, opal-spec/expectations, Expectations#be_false
      Expectations_prototype.$be_false = function() {
        
        return (__scope.Spec)._scope.BeFalseMatcher['$new'](false);
      };

      // line 37, opal-spec/expectations, Expectations#equal
      Expectations_prototype.$equal = function(expected) {
        
        return (__scope.Spec)._scope.EqualMatcher['$new'](expected);
      };

      // line 41, opal-spec/expectations, Expectations#raise_error
      Expectations_prototype.$raise_error = function(expected) {
        
        return (__scope.Spec)._scope.RaiseErrorMatcher['$new'](expected);
      };
            ;Expectations._donate(["$should", "$should_not", "$be_kind_of", "$be_nil", "$be_true", "$be_false", "$equal", "$raise_error"]);
    })(Spec);
    
  })(self);
  return (function(__base, __super){
    // line 47, opal-spec/expectations, class Object
    function Object() {};
    Object = __klass(__base, __super, "Object", Object);
    var Object_prototype = Object.prototype, __scope = Object._scope;

    Object.$include((__scope.Spec)._scope.Expectations)

  })(self, null);
})();
// lib/opal-spec/kernel.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module;
  
  return (function(__base){
    // line 1, opal-spec/kernel, module Kernel
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope, TMP_1;

    // line 2, opal-spec/kernel, Kernel#describe
    Kernel_prototype.$describe = TMP_1 = function(desc) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      return (__scope.Spec)._scope.ExampleGroup.$create(desc, block);
    };

    // line 6, opal-spec/kernel, Kernel#mock
    Kernel_prototype.$mock = function(obj) {
      
      return __scope.Object['$new']();
    };
        ;Kernel._donate(["$describe", "$mock"]);
  })(self)
})();
// lib/opal-spec/matchers.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    // line 1, opal-spec/matchers, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/matchers, class Matcher
      function Matcher() {};
      Matcher = __klass(__base, __super, "Matcher", Matcher);
      var Matcher_prototype = Matcher.prototype, __scope = Matcher._scope;

      // line 3, opal-spec/matchers, Matcher#initialize
      Matcher_prototype.$initialize = function(actual) {
        
        return this.actual = actual;
      };

      // line 7, opal-spec/matchers, Matcher#failure
      Matcher_prototype.$failure = function(message) {
        
        return this.$raise((__scope.Spec)._scope.ExpectationNotMetError, message);
      };
      ;Matcher._donate(["$initialize", "$failure"]);
    })(Spec, null);

    (function(__base, __super){
      // line 12, opal-spec/matchers, class PositiveOperatorMatcher
      function PositiveOperatorMatcher() {};
      PositiveOperatorMatcher = __klass(__base, __super, "PositiveOperatorMatcher", PositiveOperatorMatcher);
      var PositiveOperatorMatcher_prototype = PositiveOperatorMatcher.prototype, __scope = PositiveOperatorMatcher._scope;
      PositiveOperatorMatcher_prototype.actual = nil;

      // line 13, opal-spec/matchers, PositiveOperatorMatcher#==
      PositiveOperatorMatcher_prototype['$=='] = function(expected) {
        
        if (this.actual['$=='](expected)) {
          return true
          } else {
          return this.$failure("expected: " + (expected.$inspect()) + ", got: " + (this.actual.$inspect()) + " (using ==).")
        };
      }
      ;PositiveOperatorMatcher._donate(["$=="]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 22, opal-spec/matchers, class NegativeOperatorMatcher
      function NegativeOperatorMatcher() {};
      NegativeOperatorMatcher = __klass(__base, __super, "NegativeOperatorMatcher", NegativeOperatorMatcher);
      var NegativeOperatorMatcher_prototype = NegativeOperatorMatcher.prototype, __scope = NegativeOperatorMatcher._scope;
      NegativeOperatorMatcher_prototype.actual = nil;

      // line 23, opal-spec/matchers, NegativeOperatorMatcher#==
      NegativeOperatorMatcher_prototype['$=='] = function(expected) {
        
        if (this.actual['$=='](expected)) {
          return this.$failure("expected: " + (expected.$inspect()) + " not to be " + (this.actual.$inspect()) + " (using ==).")
          } else {
          return nil
        };
      }
      ;NegativeOperatorMatcher._donate(["$=="]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 30, opal-spec/matchers, class BeKindOfMatcher
      function BeKindOfMatcher() {};
      BeKindOfMatcher = __klass(__base, __super, "BeKindOfMatcher", BeKindOfMatcher);
      var BeKindOfMatcher_prototype = BeKindOfMatcher.prototype, __scope = BeKindOfMatcher._scope;
      BeKindOfMatcher_prototype.actual = nil;

      // line 31, opal-spec/matchers, BeKindOfMatcher#match
      BeKindOfMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected['$kind_of?'](this.actual)) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be a kind of " + (this.actual) + ", not " + (expected['$class']()) + ".")
        };
      }
      ;BeKindOfMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 38, opal-spec/matchers, class BeNilMatcher
      function BeNilMatcher() {};
      BeNilMatcher = __klass(__base, __super, "BeNilMatcher", BeNilMatcher);
      var BeNilMatcher_prototype = BeNilMatcher.prototype, __scope = BeNilMatcher._scope;

      // line 39, opal-spec/matchers, BeNilMatcher#match
      BeNilMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected['$nil?']()) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be nil.")
        };
      }
      ;BeNilMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 46, opal-spec/matchers, class BeTrueMatcher
      function BeTrueMatcher() {};
      BeTrueMatcher = __klass(__base, __super, "BeTrueMatcher", BeTrueMatcher);
      var BeTrueMatcher_prototype = BeTrueMatcher.prototype, __scope = BeTrueMatcher._scope;

      // line 47, opal-spec/matchers, BeTrueMatcher#match
      BeTrueMatcher_prototype.$match = function(expected) {
        
        if (expected['$=='](true)) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be true.")
        };
      }
      ;BeTrueMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 54, opal-spec/matchers, class BeFalseMatcher
      function BeFalseMatcher() {};
      BeFalseMatcher = __klass(__base, __super, "BeFalseMatcher", BeFalseMatcher);
      var BeFalseMatcher_prototype = BeFalseMatcher.prototype, __scope = BeFalseMatcher._scope;

      // line 55, opal-spec/matchers, BeFalseMatcher#match
      BeFalseMatcher_prototype.$match = function(expected) {
        
        if (expected['$=='](false)) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be false.")
        };
      }
      ;BeFalseMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 62, opal-spec/matchers, class EqualMatcher
      function EqualMatcher() {};
      EqualMatcher = __klass(__base, __super, "EqualMatcher", EqualMatcher);
      var EqualMatcher_prototype = EqualMatcher.prototype, __scope = EqualMatcher._scope;
      EqualMatcher_prototype.actual = nil;

      // line 63, opal-spec/matchers, EqualMatcher#match
      EqualMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected['$equal?'](this.actual)) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + (this.actual.$inspect()) + " to be the same as " + (expected.$inspect()) + ".")
        };
      };

      // line 69, opal-spec/matchers, EqualMatcher#not_match
      EqualMatcher_prototype.$not_match = function(expected) {
        var __a;
        if ((__a = expected['$equal?'](this.actual)) !== false && __a !== nil) {
          return this.$failure("expected " + (this.actual.$inspect()) + " not to be equal to " + (expected.$inspect()) + ".")
          } else {
          return nil
        };
      };
      ;EqualMatcher._donate(["$match", "$not_match"]);
    })(Spec, __scope.Matcher);

    (function(__base, __super){
      // line 76, opal-spec/matchers, class RaiseErrorMatcher
      function RaiseErrorMatcher() {};
      RaiseErrorMatcher = __klass(__base, __super, "RaiseErrorMatcher", RaiseErrorMatcher);
      var RaiseErrorMatcher_prototype = RaiseErrorMatcher.prototype, __scope = RaiseErrorMatcher._scope;
      RaiseErrorMatcher_prototype.actual = nil;

      // line 77, opal-spec/matchers, RaiseErrorMatcher#match
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
          return this.$failure("expected " + (this.actual) + " to be raised, but nothing was.")
          } else {
          return nil
        };
      }
      ;RaiseErrorMatcher._donate(["$match"]);
    })(Spec, __scope.Matcher);
    
  })(self)
})();
// lib/opal-spec/phantom_formatter.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    // line 1, opal-spec/phantom_formatter, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/phantom_formatter, class PhantomFormatter
      function PhantomFormatter() {};
      PhantomFormatter = __klass(__base, __super, "PhantomFormatter", PhantomFormatter);
      var PhantomFormatter_prototype = PhantomFormatter.prototype, __scope = PhantomFormatter._scope;
      PhantomFormatter_prototype.failed_examples = PhantomFormatter_prototype.examples = nil;

      // line 3, opal-spec/phantom_formatter, PhantomFormatter#initialize
      PhantomFormatter_prototype.$initialize = function() {
        
        this.examples = [];
        return this.failed_examples = [];
      };

      // line 8, opal-spec/phantom_formatter, PhantomFormatter#log_green
      PhantomFormatter_prototype.$log_green = function(str) {
        
        return console.log('\033[92m' + str + '\033[0m');
      };

      // line 12, opal-spec/phantom_formatter, PhantomFormatter#log_red
      PhantomFormatter_prototype.$log_red = function(str) {
        
        return console.log('\033[31m' + str + '\033[0m');
      };

      // line 16, opal-spec/phantom_formatter, PhantomFormatter#log
      PhantomFormatter_prototype.$log = function(str) {
        
        return console.log(str);
      };

      // line 20, opal-spec/phantom_formatter, PhantomFormatter#start
      PhantomFormatter_prototype.$start = function() {
        
        return nil;
      };

      // line 23, opal-spec/phantom_formatter, PhantomFormatter#finish
      PhantomFormatter_prototype.$finish = function() {
        var __a, __b;
        if ((__a = this.failed_examples['$empty?']()) !== false && __a !== nil) {
          this.$log("\nFinished");
          this.$log_green("" + (this.$example_count()) + " examples, 0 failures");
          return phantom.exit(0);
          } else {
          this.$log("\nFailures:");
          (__b = this.failed_examples, __b.$each_with_index._p = (__a = function(example, idx) {

            var exception = nil, $case = nil, output = nil, __a, __b;
            if (example == null) example = nil;
if (idx == null) idx = nil;

            this.$log("\n  " + ((__a = idx, __b = 1, typeof(__a) === 'number' ? __a + __b : __a['$+'](__b))) + ". " + (example.$example_group().$description()) + " " + (example.$description()));
            exception = example.$exception();
            $case = exception;if ((__scope.Spec)._scope.ExpectationNotMetError['$===']($case)) {
            output = exception.$message()
            }
            else {output = "" + (exception['$class']()) + ": " + (exception.$message()) + "\n";
            output = output['$+']("      " + (exception.$backtrace().$join("\n      ")) + "\n");};
            return this.$log_red("    " + (output));
          }, __a._s = this, __a), __b.$each_with_index());
          this.$log("\nFinished");
          this.$log_red("" + (this.$example_count()) + " examples, " + (this.failed_examples.$size()) + " failures");
          return phantom.exit(1);
        };
      };

      // line 57, opal-spec/phantom_formatter, PhantomFormatter#example_group_started
      PhantomFormatter_prototype.$example_group_started = function(group) {
        
        this.example_group = group;
        this.example_group_failed = false;
        return this.$log("\n" + (group.$description()));
      };

      // line 64, opal-spec/phantom_formatter, PhantomFormatter#example_group_finished
      PhantomFormatter_prototype.$example_group_finished = function(group) {
        
        return nil;
      };

      // line 67, opal-spec/phantom_formatter, PhantomFormatter#example_started
      PhantomFormatter_prototype.$example_started = function(example) {
        
        this.examples['$<<'](example);
        return this.example = example;
      };

      // line 72, opal-spec/phantom_formatter, PhantomFormatter#example_failed
      PhantomFormatter_prototype.$example_failed = function(example) {
        
        this.failed_examples['$<<'](example);
        this.example_group_failed = true;
        return this.$log_red("  " + (example.$description()));
      };

      // line 78, opal-spec/phantom_formatter, PhantomFormatter#example_passed
      PhantomFormatter_prototype.$example_passed = function(example) {
        
        return this.$log_green("  " + (example.$description()));
      };

      // line 82, opal-spec/phantom_formatter, PhantomFormatter#example_count
      PhantomFormatter_prototype.$example_count = function() {
        
        return this.examples.$size();
      };
      ;PhantomFormatter._donate(["$initialize", "$log_green", "$log_red", "$log", "$start", "$finish", "$example_group_started", "$example_group_finished", "$example_started", "$example_failed", "$example_passed", "$example_count"]);
    })(Spec, null)
    
  })(self)
})();
// lib/opal-spec/rspec_formatter.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    // line 1, opal-spec/rspec_formatter, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/rspec_formatter, class RSpecFormatter
      function RSpecFormatter() {};
      RSpecFormatter = __klass(__base, __super, "RSpecFormatter", RSpecFormatter);
      var RSpecFormatter_prototype = RSpecFormatter.prototype, __scope = RSpecFormatter._scope;
      RSpecFormatter_prototype.spec_collector = RSpecFormatter_prototype.example_group = RSpecFormatter_prototype.examples = RSpecFormatter_prototype.failed_examples = nil;

      // line 3, opal-spec/rspec_formatter, RSpecFormatter#initialize
      RSpecFormatter_prototype.$initialize = function() {
        
        this.examples = [];
        this.failed_examples = [];
        return this.spec_collector = spec_collector;
      };

      // line 10, opal-spec/rspec_formatter, RSpecFormatter#start
      RSpecFormatter_prototype.$start = function() {
        
        return nil;
      };

      // line 13, opal-spec/rspec_formatter, RSpecFormatter#finish
      RSpecFormatter_prototype.$finish = function() {
        
        return nil;
      };

      // line 16, opal-spec/rspec_formatter, RSpecFormatter#example_group_started
      RSpecFormatter_prototype.$example_group_started = function(group) {
        
        this.example_group = group;
        this.example_group_failed = false;
        return this.spec_collector.example_group_started(group.$description());
      };

      // line 23, opal-spec/rspec_formatter, RSpecFormatter#example_group_finished
      RSpecFormatter_prototype.$example_group_finished = function(group) {
        
        return this.spec_collector.example_group_finished(this.example_group.$description());
      };

      // line 27, opal-spec/rspec_formatter, RSpecFormatter#example_started
      RSpecFormatter_prototype.$example_started = function(example) {
        
        this.examples['$<<'](example);
        return this.example = example;
      };

      // line 32, opal-spec/rspec_formatter, RSpecFormatter#example_failed
      RSpecFormatter_prototype.$example_failed = function(example) {
        
        this.failed_examples['$<<'](example);
        this.example_group_failed = true;
        return this.spec_collector.example_failed(example.$description(), example.$exception().$message());
      };

      // line 38, opal-spec/rspec_formatter, RSpecFormatter#example_passed
      RSpecFormatter_prototype.$example_passed = function(example) {
        
        return this.spec_collector.example_passed(example.$description());
      };

      // line 42, opal-spec/rspec_formatter, RSpecFormatter#example_count
      RSpecFormatter_prototype.$example_count = function() {
        
        return this.examples.$size();
      };
      ;RSpecFormatter._donate(["$initialize", "$start", "$finish", "$example_group_started", "$example_group_finished", "$example_started", "$example_failed", "$example_passed", "$example_count"]);
    })(Spec, null)
    
  })(self)
})();
// lib/opal-spec/runner.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    // line 1, opal-spec/runner, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    (function(__base, __super){
      // line 2, opal-spec/runner, class Runner
      function Runner() {};
      Runner = __klass(__base, __super, "Runner", Runner);
      var Runner_prototype = Runner.prototype, __scope = Runner._scope;
      Runner_prototype.formatter = nil;

      // line 3, opal-spec/runner, Runner.in_browser?
      Runner['$in_browser?'] = function() {
        
        
        if (typeof(window) !== 'undefined' && typeof(document) !== 'undefined') {
          return true;
        }

        return false;
      
      };

      // line 13, opal-spec/runner, Runner.in_phantom?
      Runner['$in_phantom?'] = function() {
        
        
        if (typeof(phantom) !== 'undefined' && phantom.exit) {
          return true;
        }

        return false;
      
      };

      // line 23, opal-spec/runner, Runner.autorun
      Runner.$autorun = function() {
        var __a;
        if ((__a = this['$in_browser?']()) !== false && __a !== nil) {
          
          setTimeout(function() {
            __scope.Runner['$new']().$run();
          }, 0);
        
          } else {
          return __scope.Runner['$new']().$run()
        }
      };

      // line 35, opal-spec/runner, Runner#initialize
      Runner_prototype.$initialize = function() {
        var __a;
        if ((__a = __scope.Runner['$in_phantom?']()) !== false && __a !== nil) {
          return this.formatter = __scope.PhantomFormatter['$new']()
          } else {
          if ((__a = __scope.Runner['$in_browser?']()) !== false && __a !== nil) {
            return this.formatter = __scope.BrowserFormatter['$new']()
            } else {
            return this.formatter = __scope.RSpecFormatter['$new']()
          }
        };
      };

      // line 45, opal-spec/runner, Runner#run
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

      // line 52, opal-spec/runner, Runner#example_group_started
      Runner_prototype.$example_group_started = function(group) {
        
        return this.formatter.$example_group_started(group);
      };

      // line 56, opal-spec/runner, Runner#example_group_finished
      Runner_prototype.$example_group_finished = function(group) {
        
        return this.formatter.$example_group_finished(group);
      };

      // line 60, opal-spec/runner, Runner#example_started
      Runner_prototype.$example_started = function(example) {
        
        return this.formatter.$example_started(example);
      };

      // line 64, opal-spec/runner, Runner#example_passed
      Runner_prototype.$example_passed = function(example) {
        
        return this.formatter.$example_passed(example);
      };

      // line 68, opal-spec/runner, Runner#example_failed
      Runner_prototype.$example_failed = function(example) {
        
        return this.formatter.$example_failed(example);
      };
      ;Runner._donate(["$initialize", "$run", "$example_group_started", "$example_group_finished", "$example_started", "$example_passed", "$example_failed"]);      ;Runner._sdonate(["$in_browser?", "$in_phantom?", "$autorun"]);
    })(Spec, null)
    
  })(self)
})();
// lib/opal-spec/scratch_pad.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module;
  
  return (function(__base){
    // line 1, opal-spec/scratch_pad, module ScratchPad
    function ScratchPad() {};
    ScratchPad = __module(__base, "ScratchPad", ScratchPad);
    var ScratchPad_prototype = ScratchPad.prototype, __scope = ScratchPad._scope;

    // line 2, opal-spec/scratch_pad, ScratchPad.clear
    ScratchPad.$clear = function() {
      
      return this.record = nil
    };

    // line 6, opal-spec/scratch_pad, ScratchPad.record
    ScratchPad.$record = function(arg) {
      
      return this.record = arg
    };

    // line 10, opal-spec/scratch_pad, ScratchPad.<<
    ScratchPad['$<<'] = function(arg) {
      
      if (this.record == null) this.record = nil;

      return this.record['$<<'](arg)
    };

    // line 14, opal-spec/scratch_pad, ScratchPad.recorded
    ScratchPad.$recorded = function() {
      
      if (this.record == null) this.record = nil;

      return this.record
    };
        ;ScratchPad._sdonate(["$clear", "$record", "$<<", "$recorded"]);
  })(self)
})();
// lib/opal-spec/version.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module;
  
  return (function(__base){
    // line 1, opal-spec/version, module Spec
    function Spec() {};
    Spec = __module(__base, "Spec", Spec);
    var Spec_prototype = Spec.prototype, __scope = Spec._scope;

    __scope.VERSION = "0.1.15"
    
  })(self)
})();
// lib/opal-spec.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm;
  
  //= require opal-spec/example;
  //= require opal-spec/example_group;
  //= require opal-spec/matchers;
  //= require opal-spec/runner;
  //= require opal-spec/scratch_pad;
  //= require opal-spec/expectations;
  //= require opal-spec/browser_formatter;
  //= require opal-spec/phantom_formatter;
  //= require opal-spec/kernel;
  return //= require opal-spec/version;
})();
