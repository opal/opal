// lib/opal-jquery/document.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module;
  
  return (function(__base){
    // line 1, opal-jquery/document, module Document
    function Document() {};
    Document = __module(__base, "Document", Document);
    var Document_prototype = Document.prototype, __scope = Document._scope, TMP_1;

    // line 2, opal-jquery/document, Document.[]
    Document['$[]'] = function(selector) {
      
      return $(selector);
    };

    // line 6, opal-jquery/document, Document.find
    Document.$find = function(selector) {
      
      return this['$[]'](selector)
    };

    // line 10, opal-jquery/document, Document.id
    Document.$id = function(id) {
      
      
      var el = document.getElementById(id);

      if (!el) {
        return nil;
      }

      return $(el);
    
    };

    // line 22, opal-jquery/document, Document.parse
    Document.$parse = function(str) {
      
      return $(str);
    };

    // line 26, opal-jquery/document, Document.ready?
    Document['$ready?'] = TMP_1 = function() {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      
      if (block === nil) {
        return nil;
      }

      $(function() {
        block.$call();
      });

      return nil;
    
    };
        ;Document._sdonate(["$[]", "$find", "$id", "$parse", "$ready?"]);
  })(self)
})();
// lib/opal-jquery/http.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __klass = __opal.klass, __hash = __opal.hash;
  
  return (function(__base, __super){
    // line 7, opal-jquery/http, class HTTP
    function HTTP() {};
    HTTP = __klass(__base, __super, "HTTP", HTTP);
    var HTTP_prototype = HTTP.prototype, __scope = HTTP._scope, TMP_1, TMP_2, TMP_3, TMP_4;
    HTTP_prototype.body = HTTP_prototype.error_message = HTTP_prototype.method = HTTP_prototype.status_code = HTTP_prototype.url = HTTP_prototype.errback = HTTP_prototype.json = HTTP_prototype.ok = HTTP_prototype.settings = HTTP_prototype.callback = nil;

    // line 8, opal-jquery/http, HTTP#body
    HTTP_prototype.$body = function() {
      
      return this.body
    };

    // line 9, opal-jquery/http, HTTP#error_message
    HTTP_prototype.$error_message = function() {
      
      return this.error_message
    };

    // line 10, opal-jquery/http, HTTP#method
    HTTP_prototype.$method = function() {
      
      return this.method
    };

    // line 11, opal-jquery/http, HTTP#status_code
    HTTP_prototype.$status_code = function() {
      
      return this.status_code
    };

    // line 12, opal-jquery/http, HTTP#url
    HTTP_prototype.$url = function() {
      
      return this.url
    };

    // line 14, opal-jquery/http, HTTP.get
    HTTP.$get = TMP_1 = function(url, opts) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      if (opts == null) {
        opts = __hash()
      }
      return this['$new'](url, "GET", opts, block)['$send!']()
    };

    // line 18, opal-jquery/http, HTTP.post
    HTTP.$post = TMP_2 = function(url, opts) {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      if (opts == null) {
        opts = __hash()
      }
      return this['$new'](url, "POST", opts, block)['$send!']()
    };

    // line 22, opal-jquery/http, HTTP#initialize
    HTTP_prototype.$initialize = function(url, method, options, handler) {
      var http = nil, settings = nil;if (handler == null) {
        handler = nil
      }
      this.url = url;
      this.method = method;
      this.ok = true;
      http = this;
      settings = options.$to_native();
      if (handler !== false && handler !== nil) {
        this.callback = this.errback = handler
      };
      
      settings.data = settings.payload;
      settings.url  = url;
      settings.type = method;

      settings.success = function(str) {
        http.body = str;

        if (typeof(str) === 'object') {
          http.json = __scope.JSON.$from_object(str);
        }

        return http.$succeed();
      };

      settings.error = function(xhr, str) {
        return http.$fail();
      };
    
      return this.settings = settings;
    };

    // line 56, opal-jquery/http, HTTP#callback
    HTTP_prototype.$callback = TMP_3 = function() {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      this.callback = block;
      return this;
    };

    // line 61, opal-jquery/http, HTTP#errback
    HTTP_prototype.$errback = TMP_4 = function() {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      
      this.errback = block;
      return this;
    };

    // line 66, opal-jquery/http, HTTP#fail
    HTTP_prototype.$fail = function() {
      var __a;
      this.ok = false;
      if ((__a = this.errback) !== false && __a !== nil) {
        return this.errback.$call(this)
        } else {
        return nil
      };
    };

    // line 83, opal-jquery/http, HTTP#json
    HTTP_prototype.$json = function() {
      var __a;
      return ((__a = this.json), __a !== false && __a !== nil ? __a : __scope.JSON.$parse(this.body));
    };

    // line 98, opal-jquery/http, HTTP#ok?
    HTTP_prototype['$ok?'] = function() {
      
      return this.ok;
    };

    // line 105, opal-jquery/http, HTTP#send!
    HTTP_prototype['$send!'] = function() {
      
      $.ajax(this.settings);
      return this;
    };

    // line 110, opal-jquery/http, HTTP#succeed
    HTTP_prototype.$succeed = function() {
      var __a;
      if ((__a = this.callback) !== false && __a !== nil) {
        return this.callback.$call(this)
        } else {
        return nil
      };
    };
    ;HTTP._donate(["$body", "$error_message", "$method", "$status_code", "$url", "$initialize", "$callback", "$errback", "$fail", "$json", "$ok?", "$send!", "$succeed"]);    ;HTTP._sdonate(["$get", "$post"]);
  })(self, null)
})();
// lib/opal-jquery/jquery.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __klass = __opal.klass;
  
  
  var fn;

  if (typeof(jQuery) !== 'undefined') {
    fn = jQuery;
  }
  else if (typeof(Zepto) !== 'undefined') {
    fn = Zepto.fn.constructor;
  }
  else {
    self.$raise("no DOM library found");
  }

  return (function(__base, __super){
    // line 15, opal-jquery/jquery, class JQuery
    function JQuery() {};
    JQuery = __klass(__base, __super, "JQuery", JQuery);
    var JQuery_prototype = JQuery.prototype, __scope = JQuery._scope, TMP_1, TMP_2;

    // line 16, opal-jquery/jquery, JQuery.find
    JQuery.$find = function(selector) {
      
      return $(selector);
    };

    // line 20, opal-jquery/jquery, JQuery.id
    JQuery.$id = function(id) {
      
      return __scope.Document.$id(id)
    };

    // line 24, opal-jquery/jquery, JQuery.new
    JQuery['$new'] = function(tag) {
      if (tag == null) {
        tag = "div"
      }
      return $(document.createElement(tag));
    };

    // line 28, opal-jquery/jquery, JQuery.parse
    JQuery.$parse = function(str) {
      
      return $(str);
    };

    // line 32, opal-jquery/jquery, JQuery#[]
    JQuery_prototype['$[]'] = function(name) {
      
      return this.attr(name) || "";
    };

    JQuery_prototype['$[]='] = JQuery_prototype.attr;

    JQuery_prototype['$<<'] = JQuery_prototype.append;

    JQuery_prototype.$add_class = JQuery_prototype.addClass;

    JQuery_prototype.$after = JQuery_prototype.after;

    JQuery_prototype.$append = JQuery_prototype['$<<'];

    JQuery_prototype.$append_to = JQuery_prototype.appendTo;

    // line 85, opal-jquery/jquery, JQuery#append_to_body
    JQuery_prototype.$append_to_body = function() {
      
      return this.appendTo(document.body);
    };

    // line 89, opal-jquery/jquery, JQuery#append_to_head
    JQuery_prototype.$append_to_head = function() {
      
      return this.appendTo(document.head);
    };

    // line 105, opal-jquery/jquery, JQuery#at
    JQuery_prototype.$at = function(index) {
      
      
      var length = this.length;

      if (index < 0) {
        index += length;
      }

      if (index < 0 || index >= length) {
        return nil;
      }

      return $(this[index]);
    
    };

    JQuery_prototype.$before = JQuery_prototype.before;

    JQuery_prototype.$children = JQuery_prototype.children;

    // line 158, opal-jquery/jquery, JQuery#class_name
    JQuery_prototype.$class_name = function() {
      
      
      var first = this[0];

      if (!first) {
        return "";
      }

      return first.className || "";
    
    };

    // line 180, opal-jquery/jquery, JQuery#class_name=
    JQuery_prototype['$class_name='] = function(name) {
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        this[i].className = name;
      }
    
      return this;
    };

    JQuery_prototype.$css = JQuery_prototype.css;

    // line 215, opal-jquery/jquery, JQuery#each
    JQuery_prototype.$each = TMP_1 = function() {
      var __context, __yield;
      __yield = TMP_1._p || nil, __context = __yield._s, TMP_1._p = null;
      
      for (var i = 0, length = this.length; i < length; i++) {
      if (__yield.call(__context, $(this[i])) === __breaker) return __breaker.$v;
      };
      return this;
    };

    JQuery_prototype.$find = JQuery_prototype.find;

    // line 235, opal-jquery/jquery, JQuery#first
    JQuery_prototype.$first = function() {
      
      return this.length ? this.first() : nil;
    };

    JQuery_prototype['$has_class?'] = JQuery_prototype.hasClass;

    // line 241, opal-jquery/jquery, JQuery#html
    JQuery_prototype.$html = function() {
      
      return this.html() || "";
    };

    JQuery_prototype['$html='] = JQuery_prototype.html;

    // line 247, opal-jquery/jquery, JQuery#id
    JQuery_prototype.$id = function() {
      
      
      var first = this[0];

      if (!first) {
        return "";
      }

      return first.id || "";
    
    };

    // line 259, opal-jquery/jquery, JQuery#id=
    JQuery_prototype['$id='] = function(id) {
      
      
      var first = this[0];

      if (first) {
        first.id = id;
      }

      return this;
    
    };

    // line 271, opal-jquery/jquery, JQuery#inspect
    JQuery_prototype.$inspect = function() {
      
      
      var val, el, str, result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        el  = this[i];
        str = "<" + el.tagName.toLowerCase();

        if (val = el.id) str += (' id="' + val + '"');
        if (val = el.className) str += (' class="' + val + '"');

        result.push(str + '>');
      }

      return '[' + result.join(', ') + ']';
    
    };

    // line 289, opal-jquery/jquery, JQuery#length
    JQuery_prototype.$length = function() {
      
      return this.length;
    };

    JQuery_prototype.$next = JQuery_prototype.next;

    // line 295, opal-jquery/jquery, JQuery#on
    JQuery_prototype.$on = TMP_2 = function(name) {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      if (block === nil) {
        return nil
      };
      
      this.on(name, function() {
        return block.$call();
      });
    
      return block;
    };

    JQuery_prototype.$parent = JQuery_prototype.parent;

    JQuery_prototype.$prev = JQuery_prototype.prev;

    JQuery_prototype.$remove = JQuery_prototype.remove;

    JQuery_prototype.$remove_class = JQuery_prototype.removeClass;

    JQuery_prototype.$size = JQuery_prototype.$length;

    JQuery_prototype.$succ = JQuery_prototype.$next;

    JQuery_prototype['$text='] = JQuery_prototype.text;

    // line 320, opal-jquery/jquery, JQuery#value
    JQuery_prototype.$value = function() {
      
      return this.val() || "";
    };

    JQuery_prototype['$value='] = JQuery_prototype.val;
    ;JQuery._donate(["$[]", "['$[]=']", "['$<<']", ".$add_class", ".$after", "$append", ".$append_to", "$append_to_body", "$append_to_head", "$at", ".$before", ".$children", "$class_name", "$class_name=", ".$css", "$each", ".$find", "$first", "['$has_class?']", "$html", "['$html=']", "$id", "$id=", "$inspect", "$length", ".$next", "$on", ".$parent", ".$prev", ".$remove", ".$remove_class", "$size", "$succ", "['$text=']", "$value", "['$value=']"]);    ;JQuery._sdonate(["$find", "$id", "$new", "$parse"]);
  })(self, fn);
})();
// lib/opal-jquery/kernel.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __module = __opal.module;
  
  return (function(__base){
    // line 1, opal-jquery/kernel, module Kernel
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope;

    // line 2, opal-jquery/kernel, Kernel#alert
    Kernel_prototype.$alert = function(msg) {
      
      alert(msg);
      return nil;
    }
        ;Kernel._donate(["$alert"]);
  })(self)
})();
// lib/opal-jquery.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm;
  
  //= require opal-jquery/document;
  //= require opal-jquery/jquery;
  //= require opal-jquery/kernel;
  return //= require opal-jquery/http;
})();
