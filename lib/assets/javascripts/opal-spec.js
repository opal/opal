// lib/opal-spec/browser_formatter.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    (function(__base, __super){
      function BrowserFormatter() {};
      BrowserFormatter = __klass(__base, __super, "BrowserFormatter", BrowserFormatter);

      var BrowserFormatter_prototype = BrowserFormatter.prototype, __scope = BrowserFormatter._scope;
      BrowserFormatter_prototype.start_time = BrowserFormatter_prototype.failed_examples = BrowserFormatter_prototype.summary_element = BrowserFormatter_prototype.groups_element = BrowserFormatter_prototype.example_group_failed = BrowserFormatter_prototype.group_element = BrowserFormatter_prototype.examples = BrowserFormatter_prototype.example_list = nil;

      __scope.CSS = "\n      body {\n        font-size: 14px;\n        font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\n      }\n\n      pre {\n        font-family: \"Bitstream Vera Sans Mono\", Monaco, \"Lucida Console\", monospace;\n        font-size: 12px;\n        color: #444444;\n        white-space: pre;\n        padding: 3px 0px 3px 12px;\n        margin: 0px 0px 8px;\n\n        background: #FAFAFA;\n        -webkit-box-shadow: rgba(0,0,0,0.07) 0 1px 2px inset;\n        -webkit-border-radius: 3px;\n        -moz-border-radius: 3px;\n        border-radius: 3px;\n        border: 1px solid #DDDDDD;\n      }\n\n      ul.example_groups {\n        list-style-type: none;\n      }\n\n      li.group.passed .group_description {\n        color: #597800;\n        font-weight: bold;\n      }\n\n      li.group.failed .group_description {\n        color: #FF000E;\n        font-weight: bold;\n      }\n\n      li.example.passed {\n        color: #597800;\n      }\n\n      li.example.failed {\n        color: #FF000E;\n      }\n\n      .examples {\n        list-style-type: none;\n      }\n    ";

      BrowserFormatter_prototype.$initialize = function() {
        
        this.examples = [];
        return this.failed_examples = [];
      };

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
        styles.type = 'text/css';

        if (styles.styleSheet) {
          styles.styleSheet.cssText = __scope.CSS;
        }
        else {
          styles.appendChild(document.createTextNode(__scope.CSS));
        }

        document.getElementsByTagName('head')[0].appendChild(styles);
      
        this.start_time = __scope.Time.$now().$to_f();
        this.groups_element = groups_element;
        return this.summary_element = summary_element;
      };

      BrowserFormatter_prototype.$finish = function() {
        var time = nil, text = nil, __a, __b;
        time = (__a = __scope.Time.$now().$to_f(), __b = this.start_time, typeof(__a) === 'number' ? __a - __b : __a['$-'](__b));
        text = "\n" + (this.$example_count()) + " examples, " + (this.failed_examples.$size()) + " failures (time taken: " + (time) + ")";
        return this.summary_element.innerHTML = text;
      };

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

      BrowserFormatter_prototype.$example_group_finished = function(group) {
        var __a;
        if ((__a = this.example_group_failed) !== false && __a !== nil) {
          return this.group_element.className = 'group failed';
          } else {
          return this.group_element.className = 'group passed';
        };
      };

      BrowserFormatter_prototype.$example_started = function(example) {
        
        this.examples['$<<'](example);
        return this.example = example;
      };

      BrowserFormatter_prototype.$example_failed = function(example) {
        var exception = nil, $case = nil, output = nil;
        this.failed_examples['$<<'](example);
        this.example_group_failed = true;
        exception = example.$exception();
        $case = exception;if ((__scope.OpalSpec)._scope.ExpectationNotMetError['$===']($case)) {
        output = exception.$message()
        }
        else {output = "" + (exception.$class().$name()) + ": " + (exception.$message()) + "\n";
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

      BrowserFormatter_prototype.$example_passed = function(example) {
        
        
        var wrapper = document.createElement('li');
        wrapper.className = 'example passed';

        var description = document.createElement('span');
        description.className = 'example_description';
        description.innerHTML = example.$description();

        wrapper.appendChild(description);
        this.example_list.appendChild(wrapper);
      
      };

      BrowserFormatter_prototype.$example_count = function() {
        
        return this.examples.$size();
      };

      return nil;
    })(OpalSpec, null)
    
  })(self)
})();
// lib/opal-spec/example.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    (function(__base, __super){
      function Example() {};
      Example = __klass(__base, __super, "Example", Example);

      var Example_prototype = Example.prototype, __scope = Example._scope, TMP_1, TMP_2;
      Example_prototype.description = Example_prototype.example_group = Example_prototype.exception = Example_prototype.asynchronous = Example_prototype.__block__ = nil;

      Example_prototype.$description = function() {
        
        return this.description
      }, 
      Example_prototype.$example_group = function() {
        
        return this.example_group
      }, 
      Example_prototype.$exception = function() {
        
        return this.exception
      }, nil;

      Example_prototype.$asynchronous = function() {
        
        return this.asynchronous
      }, 
      Example_prototype['$asynchronous='] = function(val) {
        
        return this.asynchronous = val
      }, nil;

      Example_prototype.$initialize = function(group, desc, block) {
        
        this.example_group = group;
        this.description = desc;
        return this.__block__ = block;
      };

      Example_prototype.$finish_running = function() {
        var __a;
        if ((__a = this.exception) !== false && __a !== nil) {
          return this.example_group.$example_failed(this)
          } else {
          return this.example_group.$example_passed(this)
        };
      };

      Example_prototype.$run = function() {
        var e = nil, __a, __b;
        try {
        this.example_group.$example_started(this);
        this.$run_before_hooks();
        (__a = this, __a.$instance_eval._p = this.__block__.$to_proc(), __a.$instance_eval());
        } catch ($err) {
        if (true) {
        e = $err;this.exception = e}
        else { throw $err; }
        }
        finally {
        if ((__b = this.asynchronous) === false || __b === nil) {
          this.$run_after_hooks()
        }};
        if ((__b = this.asynchronous) !== false && __b !== nil) {
          return nil
          } else {
          return this.$finish_running()
        };
      };

      Example_prototype.$run_after_hooks = function() {
        var e = nil, __a, __b;
        try {
        return (__b = this.example_group.$after_hooks(), __b.$each._p = (__a = function(after) {

          var __a;
          if (after == null) after = nil;

          return (__a = this, __a.$instance_eval._p = after.$to_proc(), __a.$instance_eval())
        }, __a._s = this, __a), __b.$each())
        } catch ($err) {
        if (true) {
        e = $err;this.exception = e}
        else { throw $err; }
        };
      };

      Example_prototype.$run_before_hooks = function() {
        var __a, __b;
        return (__b = this.example_group.$before_hooks(), __b.$each._p = (__a = function(before) {

          var __a;
          if (before == null) before = nil;

          return (__a = this, __a.$instance_eval._p = before.$to_proc(), __a.$instance_eval())
        }, __a._s = this, __a), __b.$each());
      };

      Example_prototype.$run_async = TMP_1 = function() {
        var e = nil, __context, block;
        block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
        
        try {
        block.$call()
        } catch ($err) {
        if (true) {
        e = $err;this.exception = e}
        else { throw $err; }
        }
        finally {
        this.$run_after_hooks()};
        return this.$finish_running();
      };

      Example_prototype.$set_timeout = TMP_2 = function(duration) {
        var __context, block;
        block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
        
        
        setTimeout(function() {
          block.$call();
        }, duration);
      
        return this;
      };

      return nil;
    })(OpalSpec, null)
    
  })(self)
})();
// lib/opal-spec/example_group.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    (function(__base, __super){
      function ExampleGroup() {};
      ExampleGroup = __klass(__base, __super, "ExampleGroup", ExampleGroup);

      ;ExampleGroup._sdonate(["$example_groups", "$create"]);      var ExampleGroup_prototype = ExampleGroup.prototype, __scope = ExampleGroup._scope, TMP_1, TMP_2, TMP_3, TMP_4;
      ExampleGroup_prototype.examples = ExampleGroup_prototype.before_hooks = ExampleGroup_prototype.after_hooks = ExampleGroup_prototype.parent = ExampleGroup_prototype.runner = ExampleGroup_prototype.running_examples = ExampleGroup_prototype.desc = nil;

      ExampleGroup.example_groups = [];

      ExampleGroup.$example_groups = function() {
        
        if (this.example_groups == null) this.example_groups = nil;

        return this.example_groups
      };

      ExampleGroup.stack = [];

      ExampleGroup.$create = function(desc, block) {
        var group = nil, __a;
        if (this.stack == null) this.stack = nil;
        if (this.example_groups == null) this.example_groups = nil;

        group = this.$new(desc, this.stack.$last());
        this.example_groups['$<<'](group);
        this.stack['$<<'](group);
        (__a = group, __a.$instance_eval._p = block.$to_proc(), __a.$instance_eval());
        return this.stack.$pop();
      };

      ExampleGroup_prototype.$initialize = function(desc, parent) {
        
        this.desc = desc.$to_s();
        this.parent = parent;
        this.examples = [];
        this.before_hooks = [];
        return this.after_hooks = [];
      };

      ExampleGroup_prototype.$it = TMP_1 = function(desc) {
        var __context, block;
        block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
        
        return this.examples['$<<'](__scope.Example.$new(this, desc, block));
      };

      ExampleGroup_prototype.$async = TMP_2 = function(desc) {
        var example = nil, __context, block;
        block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
        
        example = __scope.Example.$new(this, desc, block);
        example['$asynchronous='](true);
        return this.examples['$<<'](example);
      };

      ExampleGroup_prototype.$it_behaves_like = function(objs) {
        objs = __slice.call(arguments, 0);
        return nil;
      };

      ExampleGroup_prototype.$before = TMP_3 = function(type) {
        var __a, __context, block;
        block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
        if (type == null) {
          type = "each"
        }
        if ((__a = type['$==']("each")) === false || __a === nil) {
          this.$raise("unsupported before type: " + (type))
        };
        return this.before_hooks['$<<'](block);
      };

      ExampleGroup_prototype.$after = TMP_4 = function(type) {
        var __a, __context, block;
        block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
        if (type == null) {
          type = "each"
        }
        if ((__a = type['$==']("each")) === false || __a === nil) {
          this.$raise("unsupported after type: " + (type))
        };
        return this.after_hooks['$<<'](block);
      };

      ExampleGroup_prototype.$before_hooks = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return [].$concat(this.parent.$before_hooks()).$concat(this.before_hooks)
          } else {
          return this.before_hooks
        };
      };

      ExampleGroup_prototype.$after_hooks = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return [].$concat(this.parent.$after_hooks()).$concat(this.after_hooks)
          } else {
          return this.after_hooks
        };
      };

      ExampleGroup_prototype.$run = function(runner) {
        
        this.runner = runner;
        this.runner.$example_group_started(this);
        this.running_examples = this.examples.$dup();
        return this.$run_next_example();
      };

      ExampleGroup_prototype.$run_next_example = function() {
        var __a;
        if ((__a = this.running_examples['$empty?']()) !== false && __a !== nil) {
          return this.runner.$example_group_finished(this)
          } else {
          return this.running_examples.$shift().$run()
        };
      };

      ExampleGroup_prototype.$example_started = function(example) {
        
        return this.runner.$example_started(example);
      };

      ExampleGroup_prototype.$example_passed = function(example) {
        
        this.runner.$example_passed(example);
        return this.$run_next_example();
      };

      ExampleGroup_prototype.$example_failed = function(example) {
        
        this.runner.$example_failed(example);
        return this.$run_next_example();
      };

      ExampleGroup_prototype.$description = function() {
        var __a;
        if ((__a = this.parent) !== false && __a !== nil) {
          return "" + (this.parent.$description()) + " " + (this.desc)
          } else {
          return this.desc
        };
      };

      return nil;
    })(OpalSpec, null)
    
  })(self)
})();
// lib/opal-spec/expectations.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;
  
  (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    (function(__base, __super){
      function ExpectationNotMetError() {};
      ExpectationNotMetError = __klass(__base, __super, "ExpectationNotMetError", ExpectationNotMetError);

      var ExpectationNotMetError_prototype = ExpectationNotMetError.prototype, __scope = ExpectationNotMetError._scope;

      return nil
    })(OpalSpec, __scope.StandardError);

    (function(__base){
      function Expectations() {};
      Expectations = __module(__base, "Expectations", Expectations);
      var Expectations_prototype = Expectations.prototype, __scope = Expectations._scope;

      Expectations_prototype.$should = function(matcher) {
        if (matcher == null) {
          matcher = nil
        }
        if (matcher !== false && matcher !== nil) {
          return matcher.$match(this)
          } else {
          return (__scope.OpalSpec)._scope.PositiveOperatorMatcher.$new(this)
        };
      };

      Expectations_prototype.$should_not = function(matcher) {
        if (matcher == null) {
          matcher = nil
        }
        if (matcher !== false && matcher !== nil) {
          return matcher.$not_match(this)
          } else {
          return (__scope.OpalSpec)._scope.NegativeOperatorMatcher.$new(this)
        };
      };

      Expectations_prototype.$be_kind_of = function(expected) {
        
        return (__scope.OpalSpec)._scope.BeKindOfMatcher.$new(expected);
      };

      Expectations_prototype.$be_nil = function() {
        
        return (__scope.OpalSpec)._scope.BeNilMatcher.$new(nil);
      };

      Expectations_prototype.$be_true = function() {
        
        return (__scope.OpalSpec)._scope.BeTrueMatcher.$new(true);
      };

      Expectations_prototype.$be_false = function() {
        
        return (__scope.OpalSpec)._scope.BeFalseMatcher.$new(false);
      };

      Expectations_prototype.$equal = function(expected) {
        
        return (__scope.OpalSpec)._scope.EqualMatcher.$new(expected);
      };

      Expectations_prototype.$raise_error = function(expected) {
        
        return (__scope.OpalSpec)._scope.RaiseErrorMatcher.$new(expected);
      };
            ;Expectations._donate(["$should", "$should_not", "$be_kind_of", "$be_nil", "$be_true", "$be_false", "$equal", "$raise_error"]);
    })(OpalSpec);
    
  })(self);
  return (function(__base, __super){
    function Object() {};
    Object = __klass(__base, __super, "Object", Object);

    var Object_prototype = Object.prototype, __scope = Object._scope;

    return Object.$include((__scope.OpalSpec)._scope.Expectations)
  })(self, null);
})();
// lib/opal-spec/kernel.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
  return (function(__base){
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope, TMP_1;

    Kernel_prototype.$describe = TMP_1 = function(desc) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      return (__scope.OpalSpec)._scope.ExampleGroup.$create(desc, block);
    };

    Kernel_prototype.$mock = function(obj) {
      
      return __scope.Object.$new();
    };
        ;Kernel._donate(["$describe", "$mock"]);
  })(self)
})();
// lib/opal-spec/matchers.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    (function(__base, __super){
      function Matcher() {};
      Matcher = __klass(__base, __super, "Matcher", Matcher);

      var Matcher_prototype = Matcher.prototype, __scope = Matcher._scope;

      Matcher_prototype.$initialize = function(actual) {
        
        return this.actual = actual;
      };

      Matcher_prototype.$failure = function(message) {
        
        return this.$raise((__scope.OpalSpec)._scope.ExpectationNotMetError, message);
      };

      return nil;
    })(OpalSpec, null);

    (function(__base, __super){
      function PositiveOperatorMatcher() {};
      PositiveOperatorMatcher = __klass(__base, __super, "PositiveOperatorMatcher", PositiveOperatorMatcher);

      var PositiveOperatorMatcher_prototype = PositiveOperatorMatcher.prototype, __scope = PositiveOperatorMatcher._scope;
      PositiveOperatorMatcher_prototype.actual = nil;

      PositiveOperatorMatcher_prototype['$=='] = function(expected) {
        
        if (this.actual['$=='](expected)) {
          return true
          } else {
          return this.$failure("expected: " + (expected.$inspect()) + ", got: " + (this.actual.$inspect()) + " (using ==).")
        };
      };

      return nil;
    })(OpalSpec, __scope.Matcher);

    (function(__base, __super){
      function NegativeOperatorMatcher() {};
      NegativeOperatorMatcher = __klass(__base, __super, "NegativeOperatorMatcher", NegativeOperatorMatcher);

      var NegativeOperatorMatcher_prototype = NegativeOperatorMatcher.prototype, __scope = NegativeOperatorMatcher._scope;
      NegativeOperatorMatcher_prototype.actual = nil;

      NegativeOperatorMatcher_prototype['$=='] = function(expected) {
        
        if (this.actual['$=='](expected)) {
          return this.$failure("expected: " + (expected.$inspect()) + " not to be " + (this.actual.$inspect()) + " (using ==).")
          } else {
          return nil
        };
      };

      return nil;
    })(OpalSpec, __scope.Matcher);

    (function(__base, __super){
      function BeKindOfMatcher() {};
      BeKindOfMatcher = __klass(__base, __super, "BeKindOfMatcher", BeKindOfMatcher);

      var BeKindOfMatcher_prototype = BeKindOfMatcher.prototype, __scope = BeKindOfMatcher._scope;
      BeKindOfMatcher_prototype.actual = nil;

      BeKindOfMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected['$kind_of?'](this.actual)) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be a kind of " + (this.actual) + ", not " + (expected.$class()) + ".")
        };
      };

      return nil;
    })(OpalSpec, __scope.Matcher);

    (function(__base, __super){
      function BeNilMatcher() {};
      BeNilMatcher = __klass(__base, __super, "BeNilMatcher", BeNilMatcher);

      var BeNilMatcher_prototype = BeNilMatcher.prototype, __scope = BeNilMatcher._scope;

      BeNilMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected['$nil?']()) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be nil.")
        };
      };

      return nil;
    })(OpalSpec, __scope.Matcher);

    (function(__base, __super){
      function BeTrueMatcher() {};
      BeTrueMatcher = __klass(__base, __super, "BeTrueMatcher", BeTrueMatcher);

      var BeTrueMatcher_prototype = BeTrueMatcher.prototype, __scope = BeTrueMatcher._scope;

      BeTrueMatcher_prototype.$match = function(expected) {
        
        if (expected['$=='](true)) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be true.")
        };
      };

      return nil;
    })(OpalSpec, __scope.Matcher);

    (function(__base, __super){
      function BeFalseMatcher() {};
      BeFalseMatcher = __klass(__base, __super, "BeFalseMatcher", BeFalseMatcher);

      var BeFalseMatcher_prototype = BeFalseMatcher.prototype, __scope = BeFalseMatcher._scope;

      BeFalseMatcher_prototype.$match = function(expected) {
        
        if (expected['$=='](false)) {
          return nil
          } else {
          return this.$failure("expected " + (expected.$inspect()) + " to be false.")
        };
      };

      return nil;
    })(OpalSpec, __scope.Matcher);

    (function(__base, __super){
      function EqualMatcher() {};
      EqualMatcher = __klass(__base, __super, "EqualMatcher", EqualMatcher);

      var EqualMatcher_prototype = EqualMatcher.prototype, __scope = EqualMatcher._scope;
      EqualMatcher_prototype.actual = nil;

      EqualMatcher_prototype.$match = function(expected) {
        var __a;
        if ((__a = expected['$equal?'](this.actual)) !== false && __a !== nil) {
          return nil
          } else {
          return this.$failure("expected " + (this.actual.$inspect()) + " to be the same as " + (expected.$inspect()) + ".")
        };
      };

      EqualMatcher_prototype.$not_match = function(expected) {
        var __a;
        if ((__a = expected['$equal?'](this.actual)) !== false && __a !== nil) {
          return this.$failure("expected " + (this.actual.$inspect()) + " not to be equal to " + (expected.$inspect()) + ".")
          } else {
          return nil
        };
      };

      return nil;
    })(OpalSpec, __scope.Matcher);

    (function(__base, __super){
      function RaiseErrorMatcher() {};
      RaiseErrorMatcher = __klass(__base, __super, "RaiseErrorMatcher", RaiseErrorMatcher);

      var RaiseErrorMatcher_prototype = RaiseErrorMatcher.prototype, __scope = RaiseErrorMatcher._scope;
      RaiseErrorMatcher_prototype.actual = nil;

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
      };

      return nil;
    })(OpalSpec, __scope.Matcher);
    
  })(self)
})();
// lib/opal-spec/phantom_formatter.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    (function(__base, __super){
      function PhantomFormatter() {};
      PhantomFormatter = __klass(__base, __super, "PhantomFormatter", PhantomFormatter);

      var PhantomFormatter_prototype = PhantomFormatter.prototype, __scope = PhantomFormatter._scope;
      PhantomFormatter_prototype.failed_examples = PhantomFormatter_prototype.examples = nil;

      PhantomFormatter_prototype.$initialize = function() {
        
        this.examples = [];
        return this.failed_examples = [];
      };

      PhantomFormatter_prototype.$log_green = function(str) {
        
        return console.log('\033[92m' + str + '\033[0m');
      };

      PhantomFormatter_prototype.$log_red = function(str) {
        
        return console.log('\033[31m' + str + '\033[0m');
      };

      PhantomFormatter_prototype.$log = function(str) {
        
        return console.log(str);
      };

      PhantomFormatter_prototype.$start = function() {
        
        return nil;
      };

      PhantomFormatter_prototype.$finish = function() {
        var __a, __b;
        if ((__a = this.failed_examples['$empty?']()) !== false && __a !== nil) {
          this.$log("\nFinished");
          this.$log_green("" + (this.$example_count()) + " examples, 0 failures");
          return this.$finish_with_code(0);
          } else {
          this.$log("\nFailures:");
          (__b = this.failed_examples, __b.$each_with_index._p = (__a = function(example, idx) {

            var exception = nil, $case = nil, output = nil, __a, __b;
            if (example == null) example = nil;
if (idx == null) idx = nil;

            this.$log("\n  " + ((__a = idx, __b = 1, typeof(__a) === 'number' ? __a + __b : __a['$+'](__b))) + ". " + (example.$example_group().$description()) + " " + (example.$description()));
            exception = example.$exception();
            $case = exception;if ((__scope.OpalSpec)._scope.ExpectationNotMetError['$===']($case)) {
            output = exception.$message()
            }
            else {output = "" + (exception.$class().$name()) + ": " + (exception.$message()) + "\n";
            output = output['$+']("      " + (exception.$backtrace().$join("\n      ")) + "\n");};
            return this.$log_red("    " + (output));
          }, __a._s = this, __a), __b.$each_with_index());
          this.$log("\nFinished");
          this.$log_red("" + (this.$example_count()) + " examples, " + (this.failed_examples.$size()) + " failures");
          return this.$finish_with_code(1);
        };
      };

      PhantomFormatter_prototype.$finish_with_code = function(code) {
        
        
        if (typeof(phantom) !== 'undefined') {
          return phantom.exit(code);
        }
        else {
          window.OPAL_SPEC_CODE = code;
        }
      
      };

      PhantomFormatter_prototype.$example_group_started = function(group) {
        
        this.example_group = group;
        this.example_group_failed = false;
        return this.$log("\n" + (group.$description()));
      };

      PhantomFormatter_prototype.$example_group_finished = function(group) {
        
        return nil;
      };

      PhantomFormatter_prototype.$example_started = function(example) {
        
        this.examples['$<<'](example);
        return this.example = example;
      };

      PhantomFormatter_prototype.$example_failed = function(example) {
        
        this.failed_examples['$<<'](example);
        this.example_group_failed = true;
        return this.$log_red("  " + (example.$description()));
      };

      PhantomFormatter_prototype.$example_passed = function(example) {
        
        return this.$log_green("  " + (example.$description()));
      };

      PhantomFormatter_prototype.$example_count = function() {
        
        return this.examples.$size();
      };

      return nil;
    })(OpalSpec, null)
    
  })(self)
})();
// lib/opal-spec/runner.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __klass = __opal.klass;
  
  return (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    (function(__base, __super){
      function Runner() {};
      Runner = __klass(__base, __super, "Runner", Runner);

      ;Runner._sdonate(["$in_browser?", "$in_phantom?", "$autorun"]);      var Runner_prototype = Runner.prototype, __scope = Runner._scope;
      Runner_prototype.formatter = Runner_prototype.groups = nil;

      Runner['$in_browser?'] = function() {
        
        
        if (typeof(window) !== 'undefined' && typeof(document) !== 'undefined') {
          return true;
        }

        return false;
      
      };

      Runner['$in_phantom?'] = function() {
        
        
        if (typeof(phantom) !== 'undefined' || typeof(OPAL_SPEC_PHANTOM) !== 'undefined') {
          return true;
        }

        return false;
      
      };

      Runner.$autorun = function() {
        var __a;
        if ((__a = this['$in_browser?']()) !== false && __a !== nil) {
          
          setTimeout(function() {
            __scope.Runner.$new().$run();
          }, 0);
        
          } else {
          return __scope.Runner.$new().$run()
        }
      };

      Runner_prototype.$initialize = function() {
        var __a;
        if ((__a = __scope.Runner['$in_phantom?']()) !== false && __a !== nil) {
          return this.formatter = __scope.PhantomFormatter.$new()
          } else {
          if ((__a = __scope.Runner['$in_browser?']()) !== false && __a !== nil) {
            return this.formatter = __scope.BrowserFormatter.$new()
            } else {
            return nil
          }
        };
      };

      Runner_prototype.$run = function() {
        
        this.groups = __scope.ExampleGroup.$example_groups().$dup();
        this.formatter.$start();
        return this.$run_next_group();
      };

      Runner_prototype.$run_next_group = function() {
        var __a;
        if ((__a = this.groups['$empty?']()) !== false && __a !== nil) {
          return this.formatter.$finish()
          } else {
          return this.groups.$shift().$run(this)
        };
      };

      Runner_prototype.$example_group_started = function(group) {
        
        return this.formatter.$example_group_started(group);
      };

      Runner_prototype.$example_group_finished = function(group) {
        
        this.formatter.$example_group_finished(group);
        return this.$run_next_group();
      };

      Runner_prototype.$example_started = function(example) {
        
        return this.formatter.$example_started(example);
      };

      Runner_prototype.$example_passed = function(example) {
        
        return this.formatter.$example_passed(example);
      };

      Runner_prototype.$example_failed = function(example) {
        
        return this.formatter.$example_failed(example);
      };

      return nil;
    })(OpalSpec, null)
    
  })(self)
})();
// lib/opal-spec/scratch_pad.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
  return (function(__base){
    function ScratchPad() {};
    ScratchPad = __module(__base, "ScratchPad", ScratchPad);
    var ScratchPad_prototype = ScratchPad.prototype, __scope = ScratchPad._scope;

    ScratchPad.$clear = function() {
      
      return this.record = nil
    };

    ScratchPad.$record = function(arg) {
      
      return this.record = arg
    };

    ScratchPad['$<<'] = function(arg) {
      
      if (this.record == null) this.record = nil;

      return this.record['$<<'](arg)
    };

    ScratchPad.$recorded = function() {
      
      if (this.record == null) this.record = nil;

      return this.record
    };
        ;ScratchPad._sdonate(["$clear", "$record", "$<<", "$recorded"]);
  })(self)
})();
// lib/opal-spec/version.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
  return (function(__base){
    function OpalSpec() {};
    OpalSpec = __module(__base, "OpalSpec", OpalSpec);
    var OpalSpec_prototype = OpalSpec.prototype, __scope = OpalSpec._scope;

    __scope.VERSION = "0.2.1"
    
  })(self)
})();
// lib/opal-spec.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice;
  
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
