class Element

  # Returns an array of elements in the document matching the given
  # css {selector}. Opal internally uses Sizzle to find elements, and
  # each element in the returned array is already wrapped by an Opal
  # {Element}.
  #
  # If no matching elements can be found in the document, then the
  # returned array is simply empty.
  #
  # @example
  #
  #     # <body>
  #     #   <div class="foo" id="a"></div>
  #     #   <div class="foo" id="b"></div>
  #     #   <p class="bar"></p>
  #     # </body>
  #
  #     Element.find('.foo')
  #     # => [<div class="foo", id="a">, <div class="foo" id="b">]
  #
  #     Element.find('.bar')
  #     # => [<p class="bar">]
  #
  #     Element.find('.baz')
  #     # => []
  #
  # @param [String] selector css selector to search for
  # @return [Array<Element>] the matching elements
  def self.find(selector)
    %x{
      var elements = Sizzle(selector);

      for (var i = 0, length = elements.length; i < length; i++) {
        elements[i] = #{ self.new `elements[i]` };
      }

      return elements;
    }
  end

  # Returns an Element instance for the native element with the given
  # {id} if it exists. If the element cannot be found then {nil} is
  # returned.
  #
  # It is important to note that this method does not cache element
  # instances. This means that calling this method twice with the same
  # element id will allocate and return two seperate instances of this
  # class which wrap the same element. The two instances will be
  # {==} however.
  #
  # @example
  #
  #     # <body>
  #     #   <div id="foo"></div>
  #     # </body>
  # 
  #     Element.id('foo')     # => <div id="foo">
  #     Element.id('bar')     # => nil
  #
  # @param [String] id element id to get
  # @return [Element, nil] matching element
  def self.id(id)
    %x{
      var el = document.getElementById(id);

      if (!el) {
        return nil;
      }

      return #{self.new `el`};
    }
  end

  # Alias to Element.id(). (FIXME: remove this?)
  def self.find_by_id(id); self.id id; end

  # Creates a new {Element} instance. This class can either create new
  # elements, or wrap existing ones. Passing a string or no args to
  # {Element.new} will create a new native element of the type {type}
  # and then wrap that.
  #
  # Alternatively a native element can be passed to this method which
  # will then become the wrapped element.
  #
  # The wrapped element is stored as the privat `el` property on the
  # receiver, but you shouldn't really access it, and instead use the
  # methods provided by this class to manipulate the element.
  #
  # @example Creating a new element
  #
  #     e = Element.new             # => <div>
  #     f = Element.new 'script'    # => <script>
  #
  # @example Wrapping an existng element
  #
  #     # <html>
  #     # <body>
  #     #   <div id="foo"></div>
  #     # </body>
  #     # </html>
  #
  #     Element.new(`document.getElementById('foo')`)
  #     # => <div id="foo">
  #
  #     Element.new(`document.body`)
  #     # => <body>
  #
  # @param [String] type the tag name or native element
  # @return [self] returns receiver
  def initialize(type = :div)
    %x{
      if (typeof(type) === 'string') {
        type = document.createElement(type);
      }
      if (!type || !type.nodeType) {
        throw new Error('not a valid element');
      }

      this.el = type;
    }
  end

  # @!group Classes

  # Add a CSS class name to this element. This method will add the
  # given class name only if it is not already set on the element.
  # Trying to add a duplicate class has no effect. This method will
  # always return the receiver for chainability.
  #
  # @example
  #
  #     # <div id="foo"></div>
  #     # <div id="bar" class="big"></div>
  #
  #     foo = Element.id 'foo'
  #     foo.add_class 'limes'     # => <div id="foo" class="limes">
  #     foo.add_class 'limes'     # => <div id="foo" class="limes">
  #
  #     bar = Element.id 'bar'
  #     bar.add_class 'title'     # => <div id="bar" class="big title">
  #     bar.add_class 'big'       # => <div id="bar" class="big title">
  #
  # @param [String] name class name to add
  # @return [Element] returns self
  def add_class(name)
    %x{
      var className = this.el.className;

      if (!className) {
        this.el.className = name;
      }
      else if ((' ' + className + ' ').indexOf(' ' + name + ' ') === -1) {
        this.el.className += (' ' + name);
      }

      return this;
    }
  end

  def class_name
    `this.el.className || ""`
  end

  def class_name=(name)
    `this.el.className = name`
  end

  def remove_class(name)
    %x{
      var className = ' ' + this.el.className + ' ';
      className = className.replace(' ' + name + ' ', ' ');
      className = className.replace(/^\\s+/, '').replace(/\\s+$/, '');

      this.el.className = className;
      return this;
    }
  end

  # @!endgroup

  # @!group Events

  def on(name, &block)
    return unless block_given?

    %x{
      var el = this.el;

      var func = function(evt) {
        block.call(block._s);
        return true;
      };

      if (el.addEventListener) {
        el.addEventListener(name, func, false);
      }
      else {
        el.attachEvent(name, func);
      }
    }
    block
  end

  # @!endgroup

  # Returns an array of elements matching the given css selector that
  # are within the context of this element. That means, that only
  # elements that are decendants of this element will be matched.
  #
  # If no elements are found, then an empty array is simply returned.
  #
  # @example
  #
  #     # <div id="foo">
  #     #   <p class="a" id="bill"></p>
  #     #   <p class="b" id="tom"></p>
  #     # </div>
  #     # <div id="bar">
  #     #   <p class="a" id="ben"></p>
  #     # </div>
  #
  #     Element.id('foo').find '.a'
  #     # => [<p id="bill" class="a">]
  #
  #     Element.id('bar').find '.b'
  #     # => []
  #
  # @param [String] selector css selector to match elements against
  # @return [Array<Element>] array of matched elements
  def find(selector)
    %x{
      var elements = Sizzle(selector, this.el);

      for (var i = 0, length = elements.length; i < length; i++) {
        elements[i] = #{ Element.new `elements[i]` };
      }

      return elements;
    }
  end

  # Hides the receiver element by setting `display: none` as a css
  # property on the element.
  #
  # @return [self] returns the element
  def hide
    %x{
      this.el.style.display = 'none';
      return this;
    }
  end

  # Remove the element from the DOM. This method will try to remove this
  # element from it's parent (if it has one). If the element is not
  # currently in the DOM then there is no affect.
  #
  # @return [self] the element is returned
  def remove
    %x{
      var el = this.el, parent = el.parentNode;

      if (parent)
        parent.removeChild(el);

      return this;
    }
  end

  # Attempts to make the element visible by removing any `display` css
  # property on the element itself. This will only affect elements that
  # have been hidden with a direct style property and will **not**
  # overwrite any styles from a stylesheet.
  #
  # @return [self] returns the element
  def show
    %x{
      this.el.style.display = '';
      return this;
    }
  end

  # Returns whether this element is visible or not.
  # @return [true, false] return if element is visible or not
  def visible?
    `this.el.style.display !== 'none'`
  end

  def append_to_body
    %x{
      document.body.appendChild(this.el);
      return this;
    }
  end

  def id
    `this.el.id`
  end

  def id=(id)
    `this.el.id = id`
  end

  def inspect
    %x{
      var val, el = this.el, str = '<' + el.tagName.toLowerCase();

      if (val = el.id) str += (' id="' + val + '"');
      if (val = el.className) str += (' class="' + val + '"');

      return str + '>';
    }
  end

  alias to_s inspect

  def empty?
    `!!(/^\s*$/.test(this.el.innerHTML))`
  end

  def clear
    %x{
      var el = this.el;

      while (el.firstChild)
        el.removeChild(el.firstChild);

      return this;
    }
  end

  def ==(other)
    `this.el === other.el`
  end

  def html=(html)
    `this.el.innerHTML = html`
  end

  def append(child)
    `this.el.appendChild(child.el)`
  end

  def tag
    %x{
      var tag = this.el.tagName;
      return tag ? tag.toLowerCase() : '';
    }
  end

  def has_class?(name)
    %x{
      var full = this.el.className;

      if (full === name) return true;
      if (full === '') return false;

      return (new RegExp("(^|\\s+)" + name + "(\\s+|$)")).test(full);
    }
  end
end
