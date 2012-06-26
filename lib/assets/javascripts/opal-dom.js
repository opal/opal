// file lib/opal/dom/depreceated.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;

  return (function(__base, __super){
    // line 1, lib/opal/dom/depreceated.rb, class DOM
    function DOM() {};
    DOM = __klass(__base, __super, "DOM", DOM);
    var DOM_prototype = DOM.prototype, __scope = DOM._scope;

    // line 2, lib/opal/dom/depreceated.rb, DOM.parse
    DOM.$parse = function(str) {
      
      
      var el = document.createElement('div');
      // awkward IE
      el.innerHTML = "_" + str;

      var child = el.firstChild;

      while (child) {
        if (child.nodeType !== 1) {
          child = child.nextSibling
          continue;
        }

        return __scope.Element.$new(child)
      }

      this.$raise("no DOM node in content")
    
    }
    ;DOM._sdonate(["$parse"]);
  })(self, null)
})();
// file lib/opal/dom/document.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;

  return (function(__base){
    // line 1, lib/opal/dom/document.rb, module Document
    function Document() {};
    Document = __module(__base, "Document", Document);
    var Document_prototype = Document.prototype, __scope = Document._scope, TMP_1;

    // line 2, lib/opal/dom/document.rb, Document.body_ready?
    Document.$body_ready$p = function() {
      
      return !!(document && document.body);
    };

    // line 6, lib/opal/dom/document.rb, Document.ready?
    Document.$ready$p = TMP_1 = function() {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      setTimeout(function() { block.call(block._s); }, 0)
    };
        ;Document._sdonate(["$body_ready$p", "$ready$p"]);
  })(self)
})();
// file lib/opal/dom/element.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;

  return (function(__base, __super){
    // line 1, lib/opal/dom/element.rb, class Element
    function Element() {};
    Element = __klass(__base, __super, "Element", Element);
    var supports_inner_html = nil, Element_prototype = Element.prototype, __scope = Element._scope, __a;

    // line 5, lib/opal/dom/element.rb, Element.[]
    Element.$aref$ = function(str) {
      
      return this.$Element(str)
    };

    // line 27, lib/opal/dom/element.rb, Element#initialize
    Element_prototype.$initialize = function(el) {
      if (el == null) {
        el = "div"
      }
      
      if (typeof(el) === 'string') {
        el = document.createElement(el);
      }

      if (!el || !el.nodeType) {
        throw new Error('not a valid element');
      }

      this.el = el;
    
    };

    // line 41, lib/opal/dom/element.rb, Element#<<
    Element_prototype.$lshft$ = function(content) {
      
      return this.el.appendChild(content.el);
    };

    Element_prototype.$append = Element_prototype.$lshft$;

    // line 47, lib/opal/dom/element.rb, Element#append_to_body
    Element_prototype.$append_to_body = function() {
      
      
      document.body.appendChild(this.el);
      return this;
    
    };

    // line 54, lib/opal/dom/element.rb, Element#append_to_head
    Element_prototype.$append_to_head = function() {
      
      
      document.getElementsByTagName('head')[0].appendChild(this.el);
      return this;
    
    };

    // line 70, lib/opal/dom/element.rb, Element#add_class
    Element_prototype.$add_class = function(name) {
      
      
      var el = this.el, className = el.className;

      if (!className) {
        el.className = name;
      }
      else if((' ' + className + ' ').indexOf(' ' + name + ' ') === -1) {
        el.className += (' ' + name);
      }

      return this;
    
    };

    // line 97, lib/opal/dom/element.rb, Element#has_class?
    Element_prototype.$has_class$p = function(name) {
      
      return (' ' + this.el.className + ' ').indexOf(' ' + name + ' ') !== -1;
    };

    // line 101, lib/opal/dom/element.rb, Element#id
    Element_prototype.$id = function() {
      
      return this.el.id;
    };

    // line 105, lib/opal/dom/element.rb, Element#inspect
    Element_prototype.$inspect = function() {
      
      
      var val, el = this.el, str = '<' + el.tagName.toLowerCase();

      if (val = el.id) str += (' id="' + val + '"');
      if (val = el.className) str += (' class="' + val + '"');

      return str + '>';
    
    };

    // line 116, lib/opal/dom/element.rb, Element#class_name
    Element_prototype.$class_name = function() {
      
      
      return this.el.className || '';
    
    };

    // line 122, lib/opal/dom/element.rb, Element#class_name=
    Element_prototype.$class_name$e = function(name) {
      
      
      return this.el.className = name;
    
    };

    // line 137, lib/opal/dom/element.rb, Element#next
    Element_prototype.$next = function() {
      
      return this.$sibling("nextSibling");
    };

    // line 150, lib/opal/dom/element.rb, Element#prev
    Element_prototype.$prev = function() {
      
      return this.$sibling("previousSibling");
    };

    // line 163, lib/opal/dom/element.rb, Element#remove_class
    Element_prototype.$remove_class = function(name) {
      
      
      var el = this.el, className = ' ' + el.className + ' ';

      className = className.replace(' ' + name + ' ', ' ');
      className = className.replace(/^\s+/, '').replace(/\s+$/, '');

      el.className = className;

      return this;
    
    };

    // line 176, lib/opal/dom/element.rb, Element#remove
    Element_prototype.$remove = function() {
      
      
      var el = this.el, parent = el.parentNode;

      if (parent) {
        parent.removeChild(el);
      }

      return this;
    
    };

    // line 189, lib/opal/dom/element.rb, Element#sibling
    Element_prototype.$sibling = function(type) {
      
      
      var el = this.el;

      while (el = el[type]) {
        if (el.nodeType !== 1) {
          continue;
        }

        return __scope.Element.$new(el)
      }

      return nil;
    
    };

    Element_prototype.$succ = Element_prototype.$next;

    // line 207, lib/opal/dom/element.rb, Element#hide
    Element_prototype.$hide = function() {
      
      
      this.el.style.display = 'none';
      return this;
    
    };

    // line 214, lib/opal/dom/element.rb, Element#show
    Element_prototype.$show = function() {
      
      
      this.el.style.display = '';
      return this;
    
    };

    // line 228, lib/opal/dom/element.rb, Element#clear
    Element_prototype.$clear = function() {
      
      
      var el = this.el;

      while (el.firstChild) {
        el.removeChild(el.firstChild);
      }

      return this;
    
    };

    // line 240, lib/opal/dom/element.rb, Element#css
    Element_prototype.$css = function(name, value) {
      
      
      if (value == null) {
        return this.el.style[name];
      }

      return this.el.style[name] = value;
    
    };

    // line 258, lib/opal/dom/element.rb, Element#html
    Element_prototype.$html = function() {
      
      return this.el.innerHTML;
    };

    // line 272, lib/opal/dom/element.rb, Element#html=
    Element_prototype.$html$e = function(html) {
      
      
      this.el.innerHTML = html;

      return this;
    
    };

    supports_inner_html = true;

    
      try {
        var table = document.createElement('table');
        table.innerHTML = "<tr><td></td></tr>";
      } catch (err) {
        supports_inner_html = false;
      }
    

    if ((__a = supports_inner_html) === false || __a === nil) {
      // line 293, lib/opal/dom/element.rb, Element#html=
      Element_prototype.$html$e = function(html) {
        
        this.el.innerHTML = html;
        return this;
      }
    };

    // line 301, lib/opal/dom/element.rb, Element#text
    Element_prototype.$text = function() {
      
      return text_value(this.el);
    };

    // line 305, lib/opal/dom/element.rb, Element#text=
    Element_prototype.$text$e = function(str) {
      
      this.$clear();
      this.el.appendChild(document.createTextNode(str));
      return this;
    };

    
    function text_value(el) {
      var type = el.nodeType, result = '';

      if (type === 1 || type === 9 || type === 11) {
        if (typeof(el.textContent) === 'string') {
          return el.textContent;
        }
        else if (typeof(el.innerText) === 'string') {
          return el.innerText.replace(/\r/g, '');
        }
        else {
          for (var c = el.firstChild; c; c = c.nextSibling) {
            result += text_value(c);
          }
        }
      }
      else if (type === 3 || type === 4) {
        return el.nodeValue;
      }

      return result;
    }
  
    ;Element._donate(["$initialize", "$lshft$", "$append", "$append_to_body", "$append_to_head", "$add_class", "$has_class$p", "$id", "$inspect", "$class_name", "$class_name$e", "$next", "$prev", "$remove_class", "$remove", "$sibling", "$succ", "$hide", "$show", "$clear", "$css", "$html", "$html$e", "$html$e", "$text", "$text$e"]);    ;Element._sdonate(["$aref$"]);
  })(self, null)
})();
// file lib/opal/dom/element_set.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;

  return (function(__base, __super){
    // line 11, lib/opal/dom/element_set.rb, class ElementSet
    function ElementSet() {};
    ElementSet = __klass(__base, __super, "ElementSet", ElementSet);
    var ElementSet_prototype = ElementSet.prototype, __scope = ElementSet._scope, TMP_1;

    // line 19, lib/opal/dom/element_set.rb, ElementSet#initialize
    ElementSet_prototype.$initialize = function(selector, context) {
      
      return this.length = 0;
    };

    // line 24, lib/opal/dom/element_set.rb, ElementSet#each
    ElementSet_prototype.$each = TMP_1 = function() {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, this[i]) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 32, lib/opal/dom/element_set.rb, ElementSet#length
    ElementSet_prototype.$length = function() {
      
      return this.length;
    };

    ElementSet_prototype.$size = ElementSet_prototype.$length;
    ;ElementSet._donate(["$initialize", "$each", "$length", "$size"]);
  })(self, null)
})();
// file lib/opal/dom/event.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;

  return (function(__base, __super){
    // line 1, lib/opal/dom/event.rb, class Event
    function Event() {};
    Event = __klass(__base, __super, "Event", Event);
    var Event_prototype = Event.prototype, __scope = Event._scope;
    Event_prototype.alt = Event_prototype.ctrl = Event_prototype.meta = Event_prototype.shift = nil;

    // line 2, lib/opal/dom/event.rb, Event#initialize
    Event_prototype.$initialize = function(evt) {
      
      
      this.evt = evt;

      this.alt   = evt.altKey;
      this.ctrl  = evt.ctrlKey;
      this.meta  = evt.metaKey;
      this.shift = evt.shiftKey;
    
    };

    // line 13, lib/opal/dom/event.rb, Event#alt?
    Event_prototype.$alt$p = function() {
      
      return this.alt;
    };

    // line 17, lib/opal/dom/event.rb, Event#ctrl?
    Event_prototype.$ctrl$p = function() {
      
      return this.ctrl;
    };

    // line 21, lib/opal/dom/event.rb, Event#meta?
    Event_prototype.$meta$p = function() {
      
      return this.meta;
    };

    // line 35, lib/opal/dom/event.rb, Event#stop
    Event_prototype.$stop = function() {
      
      this.$prevent_default();
      return this.$stop_propagation();
    };

    // line 40, lib/opal/dom/event.rb, Event#prevent_default
    Event_prototype.$prevent_default = function() {
      
      
      var evt = this.evt;

      if (evt.preventDefault) {
        evt.preventDefault()
      }
      else {
        evt.returnValue = false;
      }

      return this;
    
    };

    // line 55, lib/opal/dom/event.rb, Event#shift?
    Event_prototype.$shift$p = function() {
      
      return this.shift;
    };

    // line 59, lib/opal/dom/event.rb, Event#stop_propagation
    Event_prototype.$stop_propagation = function() {
      
      
      var evt = this.evt;

      if (evt.stopPropagation) {
        evt.stopPropagation();
      }
      else {
        evt.cancelBubble = true;
      }

      return this;
    
    };
    ;Event._donate(["$initialize", "$alt$p", "$ctrl$p", "$meta$p", "$stop", "$prevent_default", "$shift$p", "$stop_propagation"]);
  })(self, null)
})();
// file lib/opal/dom/events.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;

  return (function(__base, __super){
    // line 1, lib/opal/dom/events.rb, class Element
    function Element() {};
    Element = __klass(__base, __super, "Element", Element);
    var Element_prototype = Element.prototype, __scope = Element._scope, __a, __b, TMP_2, TMP_3;

    __scope.EVENTS = ["click", "mousedown", "mouseup"];

    (__b = __scope.EVENTS, __b.$each._p = (__a = function(evt) {

      var TMP_1, __a, __b;
      if (evt == null) evt = nil;

      return (__b = this, __b.$define_method._p = (__a = TMP_1 = function() {

        var handler, __context, __a;
        
        handler = TMP_1._p || nil, __context = handler._s, TMP_1.p = null;
        
        return (__a = this, __a.$add_listener._p = handler.$to_proc(), __a.$add_listener(evt))
      }, __a._s = this, __a), __b.$define_method(evt))
    }, __a._s = Element, __a), __b.$each());

    // line 49, lib/opal/dom/events.rb, Element#add_listener
    Element_prototype.$add_listener = TMP_2 = function(type) {
      var __context, handler;
      handler = TMP_2._p || nil, __context = handler._s, TMP_2._p = null;
      
      
      var el = this.el, responder = function(event) {
        if (!event) {
          var event = window.event;
        }
        var evt = __scope.Event.$new(event);
        return handler.call(handler._s, evt);
      };

      if (el.addEventListener) {
        el.addEventListener(type, responder, false);
      }
      else if (el.attachEvent) {
        el.attachEvent('on' + type, responder);
      }

      return handler;
    
    };

    // line 70, lib/opal/dom/events.rb, Element#remove_listener
    Element_prototype.$remove_listener = TMP_3 = function(type) {
      var __context, handler;
      handler = TMP_3._p || nil, __context = handler._s, TMP_3._p = null;
      
      return nil;
    };
    ;Element._donate(["$add_listener", "$remove_listener"]);
  })(self, null)
})();
// file lib/opal/dom/http.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;

  return (function(__base, __super){
    // line 1, lib/opal/dom/http.rb, class HTTP
    function HTTP() {};
    HTTP = __klass(__base, __super, "HTTP", HTTP);
    var HTTP_prototype = HTTP.prototype, __scope = HTTP._scope;

    
    var make_xhr = function() {
      if (typeof XMLHttpRequest !== 'undefined' && (window.location.protocol !== 'file:' || !window.ActiveXObject)) {
        return new XMLHttpRequest();
      } else {
        try {
          return new ActiveXObject('Msxml2.XMLHTTP.6.0');
        } catch(e) { }
        try {
          return new ActiveXObject('Msxml2.XMLHTTP.3.0');
        } catch(e) { }
        try {
          return new ActiveXObject('Msxml2.XMLHTTP');
        } catch(e) { }
      }

      HTTP.$raise("Cannot make request");
    }
  

    // line 22, lib/opal/dom/http.rb, HTTP#initialize
    HTTP_prototype.$initialize = function() {
      
      
      this.xhr = make_xhr();
    
    };

    // line 28, lib/opal/dom/http.rb, HTTP#ok?
    HTTP_prototype.$ok$p = function() {
      
      return this.status >= 200 && this.status < 300;
    };
    ;HTTP._donate(["$initialize", "$ok$p"]);
  })(self, null)
})();
// file lib/opal/dom/kernel.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;

  return (function(__base){
    // line 1, lib/opal/dom/kernel.rb, module Kernel
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope;

    // line 13, lib/opal/dom/kernel.rb, Kernel#Element
    Kernel_prototype.$Element = function(selector) {
      
      
      var el

      if (selector.charAt(0) === '#') {
        el = document.getElementById(selector.substr(1));

        if (el) {
          return __scope.Element.$new(el);
        }
        else {
          return nil;
        }
      }
      else {
        return __scope.DOM.$parse(selector)
      }

      return nil;
    
    };

    // line 43, lib/opal/dom/kernel.rb, Kernel#alert
    Kernel_prototype.$alert = function(msg) {
      
      alert(msg);
      return this;
    };
        ;Kernel._donate(["$Element", "$alert"]);
  })(self)
})();
// file lib/opal/dom/version.rb
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;

  return (function(__base, __super){
    // line 1, lib/opal/dom/version.rb, class DOM
    function DOM() {};
    DOM = __klass(__base, __super, "DOM", DOM);
    var DOM_prototype = DOM.prototype, __scope = DOM._scope;

    __scope.VERSION = "0.0.1"

  })(self, null)
})();
