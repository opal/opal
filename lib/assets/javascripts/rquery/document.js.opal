module Document

  # Returns the body element of the current page as an {Element}
  # instance. Returns nil if the document hasn't finished loading
  # (which might mean the body isn't actually ready yet).
  #
  # @example
  #
  #     Document.body     # => <body>
  #
  # @return [Element, nil] return this documents body element
  def self.body
    %x{
      if (this.body) {
        return this.body;
      }

      if (document.body) {
        return this.body = #{ Element.new `document.body` };
      }

      return nil;
    }
  end

  # Returns the head element of this document as an {Element}.
  #
  # @return [Element] head element
  def self.head
    %x{
      if (!this.head) {
        var head = document.getElementsByTagName('head')[0]
        this.head = #{ Element.new `head` };
      }

      return this.head;
    }
  end

  %x{
    var loaded = false, callbacks = [];

    var trigger = function() {
      if (loaded) return;
      loaded = true;

      for (var i = 0, length = callbacks.length; i < length; i++) {
        var callback = callbacks[i];
        callback.call(callback._s);
      }
    };

    if (document.addEventListener) {
      document.addEventListener('DOMContentLoaded', trigger, false);
    }
    else {
      console.log("No Document.ready? in this browser");
    }
  }

  # Used to both register blocks that should be once the Document is
  # ready, as well as returning a boolean to indicate the ready state.
  #
  # Multiple blocks can be passed to this method which will then be run
  # in order once the Document becomes ready. If no block is given then
  # the ready state is just returned.
  #
  # The ready state is an indication of whether the document is ready
  # for manipulation. Commonly, until the document is ready, there is
  # no guarantee that the {body} element is created.
  #
  # This method will also try and perform in a cross browser way to
  # eliminate any differences between browsers and their ready state.
  #
  # @example
  #
  #     Document.ready? do
  #       puts "Document is ready and loaded!"
  #     end
  #
  #     Document.ready?     # => false
  #     # page load...
  #     Document.ready?     # => true
  #
  # @return [true, false] document ready state  
  def self.ready?(&block)
    %x{
      if (block && block !== nil) {
        if (loaded) {
          block.call(block._s);
        }
        else {
          callbacks.push(block);
        }
      }

      return loaded;
    }
  end
end
