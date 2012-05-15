class Element
  def self.find_by_id(id)
    %x{
      var el = document.getElementById(id);

      if (!el) {
        return nil;
      }

      return #{self.new `el`};
    }
  end

  def initialize(type = :div)
    %x{
      if (typeof(type) === 'string') {
        type = document.createElement(type);
      }
      if (!type) {// || !type.nodeType)
        throw new Error('not a valid element');
      }

      this.el = type;
    }
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
    `self.el === other.el`
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
end