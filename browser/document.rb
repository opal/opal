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
end