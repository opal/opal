// lib/opal-jquery/document.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
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

    // line 40, opal-jquery/document, Document.title
    Document.$title = function() {
      
      return document.title;
    };

    // line 44, opal-jquery/document, Document.title=
    Document['$title='] = function(title) {
      
      return document.title = title;
    };
        ;Document._sdonate(["$[]", "$find", "$id", "$parse", "$ready?", "$title", "$title="]);
  })(self)
})();
// lib/opal-jquery/element.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    // line 3, opal-jquery/element, class Element
    function Element() {};
    Element = __klass(__base, __super, "Element", Element);
    var Element_prototype = Element.prototype, __scope = Element._scope, TMP_1, TMP_2, TMP_3;

    // line 4, opal-jquery/element, Element.find
    Element.$find = function(selector) {
      
      return $(selector);
    };

    // line 8, opal-jquery/element, Element.id
    Element.$id = function(id) {
      
      return __scope.Document.$id(id)
    };

    // line 12, opal-jquery/element, Element.new
    Element.$new = function(tag) {
      if (tag == null) {
        tag = "div"
      }
      return $(document.createElement(tag));
    };

    // line 16, opal-jquery/element, Element.parse
    Element.$parse = function(str) {
      
      return $(str);
    };

    // line 20, opal-jquery/element, Element#[]
    Element_prototype['$[]'] = function(name) {
      
      return this.attr(name) || "";
    };

    Element_prototype['$[]='] = Element_prototype.attr;

    Element_prototype['$<<'] = Element_prototype.append;

    Element_prototype.$add_class = Element_prototype.addClass;

    Element_prototype.$after = Element_prototype.after;

    Element_prototype.$append = Element_prototype['$<<'];

    Element_prototype.$append_to = Element_prototype.appendTo;

    // line 73, opal-jquery/element, Element#append_to_body
    Element_prototype.$append_to_body = function() {
      
      return this.appendTo(document.body);
    };

    // line 77, opal-jquery/element, Element#append_to_head
    Element_prototype.$append_to_head = function() {
      
      return this.appendTo(document.head);
    };

    // line 93, opal-jquery/element, Element#at
    Element_prototype.$at = function(index) {
      
      
      var length = this.length;

      if (index < 0) {
        index += length;
      }

      if (index < 0 || index >= length) {
        return nil;
      }

      return $(this[index]);
    
    };

    Element_prototype.$before = Element_prototype.before;

    Element_prototype.$children = Element_prototype.children;

    // line 146, opal-jquery/element, Element#class_name
    Element_prototype.$class_name = function() {
      
      
      var first = this[0];

      if (!first) {
        return "";
      }

      return first.className || "";
    
    };

    // line 168, opal-jquery/element, Element#class_name=
    Element_prototype['$class_name='] = function(name) {
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        this[i].className = name;
      }
    
      return this;
    };

    // line 196, opal-jquery/element, Element#css
    Element_prototype.$css = function(name, value) {
      var __a, __b;if (value == null) {
        value = nil
      }
      if ((__a = (__b = value['$nil?'](), __b !== false && __b !== nil ? name['$is_a?'](__scope.String) : __b)) !== false && __a !== nil) {
        return $(this).css(name)
        } else {
        if ((__a = name['$is_a?'](__scope.Hash)) !== false && __a !== nil) {
          $(this).css(name.$to_native());
          } else {
          $(this).css(name, value);
        }
      };
      return this;
    };

    // line 220, opal-jquery/element, Element#animate
    Element_prototype.$animate = TMP_1 = function(params) {
      var speed = nil, __a, __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      speed = (function() { if ((__a = params['$has_key?']("speed")) !== false && __a !== nil) {
        return params.$delete("speed")
        } else {
        return 400
      }; return nil; }).call(this);
      
      $(this).animate(params.$to_native(), speed, function() {
        if ((block !== nil)) {
        block.$call()
      }
      })
    ;
    };

    // line 237, opal-jquery/element, Element#each
    Element_prototype.$each = TMP_2 = function() {
      var __context, __yield;
      __yield = TMP_2._p || nil, __context = __yield._s, TMP_2._p = null;
      
      for (var i = 0, length = this.length; i < length; i++) {
      if (__yield.call(__context, $(this[i])) === __breaker) return __breaker.$v;
      };
      return this;
    };

    Element_prototype.$find = Element_prototype.find;

    // line 257, opal-jquery/element, Element#first
    Element_prototype.$first = function() {
      
      return this.length ? this.first() : nil;
    };

    Element_prototype.$focus = Element_prototype.focus;

    Element_prototype['$has_class?'] = Element_prototype.hasClass;

    // line 265, opal-jquery/element, Element#html
    Element_prototype.$html = function() {
      
      return this.html() || "";
    };

    Element_prototype['$html='] = Element_prototype.html;

    // line 271, opal-jquery/element, Element#id
    Element_prototype.$id = function() {
      
      
      var first = this[0];

      if (!first) {
        return "";
      }

      return first.id || "";
    
    };

    // line 283, opal-jquery/element, Element#id=
    Element_prototype['$id='] = function(id) {
      
      
      var first = this[0];

      if (first) {
        first.id = id;
      }

      return this;
    
    };

    // line 295, opal-jquery/element, Element#inspect
    Element_prototype.$inspect = function() {
      
      
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

    // line 313, opal-jquery/element, Element#length
    Element_prototype.$length = function() {
      
      return this.length;
    };

    Element_prototype.$next = Element_prototype.next;

    // line 319, opal-jquery/element, Element#off
    Element_prototype.$off = function(event_name, selector, handler) {
      if (handler == null) {
        handler = nil
      }
      
      if (handler === nil) {
        handler = selector;
        this.off(event_name, handler._jq);
      }
      else {
        this.off(event_name, selector, handler._jq);
      }
    
      return handler;
    };

    // line 333, opal-jquery/element, Element#on
    Element_prototype.$on = TMP_3 = function(event_name, selector) {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      if (selector == null) {
        selector = nil
      }
      if (block === nil) {
        return nil
      };
      
      var handler = function(e) { return block.$call(e) };
      block._jq = handler;

      if (selector === nil) {
        this.on(event_name, handler);
      }
      else {
        this.on(event_name, selector, handler);
      }
    
      return block;
    };

    Element_prototype.$parent = Element_prototype.parent;

    Element_prototype.$prev = Element_prototype.prev;

    Element_prototype.$remove = Element_prototype.remove;

    Element_prototype.$remove_class = Element_prototype.removeClass;

    Element_prototype.$size = Element_prototype.$length;

    Element_prototype.$succ = Element_prototype.$next;

    Element_prototype['$text='] = Element_prototype.text;

    Element_prototype.$toggle_class = Element_prototype.toggleClass;

    Element_prototype.$trigger = Element_prototype.trigger;

    // line 369, opal-jquery/element, Element#value
    Element_prototype.$value = function() {
      
      return this.val() || "";
    };

    Element_prototype['$value='] = Element_prototype.val;

    Element_prototype.$hide = Element_prototype.hide;

    Element_prototype.$show = Element_prototype.show;

    Element_prototype.$toggle = Element_prototype.toggle;
    ;Element._sdonate(["$find", "$id", "$new", "$parse"]);
  })(self, jQuery)
})();
// lib/opal-jquery/event.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    // line 1, opal-jquery/event, class Event
    function Event() {};
    Event = __klass(__base, __super, "Event", Event);
    var Event_prototype = Event.prototype, __scope = Event._scope;

    // line 2, opal-jquery/event, Event#current_target
    Event_prototype.$current_target = function() {
      
      return $(this.currentTarget);
    };

    Event_prototype['$default_prevented?'] = Event_prototype.isDefaultPrevented;

    Event_prototype.$prevent_default = Event_prototype.preventDefault;

    // line 10, opal-jquery/event, Event#page_x
    Event_prototype.$page_x = function() {
      
      return this.pageX;
    };

    // line 14, opal-jquery/event, Event#page_y
    Event_prototype.$page_y = function() {
      
      return this.pageY;
    };

    Event_prototype['$propagation_stopped?'] = Event_prototype.propagationStopped;

    Event_prototype.$stop_propagation = Event_prototype.stopPropagation;

    // line 22, opal-jquery/event, Event#target
    Event_prototype.$target = function() {
      
      
      if (this._opalTarget) {
        return this._opalTarget;
      }
      
      return this._opalTarget = $(this.target);
    
    };

    // line 32, opal-jquery/event, Event#type
    Event_prototype.$type = function() {
      
      return this.type;
    };

    // line 36, opal-jquery/event, Event#which
    Event_prototype.$which = function() {
      
      return this.which;
    };

  })(self, $.Event)
})();
// lib/opal-jquery/http.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass, __hash = __opal.hash;
  
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
      return this.$new(url, "GET", opts, block)['$send!']()
    };

    // line 18, opal-jquery/http, HTTP.post
    HTTP.$post = TMP_2 = function(url, opts) {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      if (opts == null) {
        opts = __hash()
      }
      return this.$new(url, "POST", opts, block)['$send!']()
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
    ;HTTP._sdonate(["$get", "$post"]);
  })(self, null)
})();
// lib/opal-jquery/kernel.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
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
// lib/opal-jquery/local_storage.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
  return (function(__base){
    // line 1, opal-jquery/local_storage, module LocalStorage
    function LocalStorage() {};
    LocalStorage = __module(__base, "LocalStorage", LocalStorage);
    var LocalStorage_prototype = LocalStorage.prototype, __scope = LocalStorage._scope;

    // line 2, opal-jquery/local_storage, LocalStorage.[]
    LocalStorage['$[]'] = function(key) {
      
      
      var val = localStorage.getItem(key);
      return val === null ? nil : val;
    
    };

    // line 9, opal-jquery/local_storage, LocalStorage.[]=
    LocalStorage['$[]='] = function(key, value) {
      
      return localStorage.setItem(key, value);
    };

    // line 13, opal-jquery/local_storage, LocalStorage.clear
    LocalStorage.$clear = function() {
      
      localStorage.clear();
      return this;
    };

    // line 18, opal-jquery/local_storage, LocalStorage.delete
    LocalStorage.$delete = function(key) {
      
      
      var val = localStorage.getItem(key);
      localStorage.removeItem(key);
      return val === null ? nil : val;
    
    };
        ;LocalStorage._sdonate(["$[]", "$[]=", "$clear", "$delete"]);
  })(self)
})();
// lib/opal-jquery.rb
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice;
  
  //= require opal-jquery/document;
  //= require opal-jquery/element;
  //= require opal-jquery/kernel;
  return //= require opal-jquery/http;
})();
