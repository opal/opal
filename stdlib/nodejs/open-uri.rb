module OpenURI

  @__xmlhttprequest__ = node_require :xmlhttprequest
  `var __XMLHttpRequest__ = #{@__xmlhttprequest__}.XMLHttpRequest`

  def self.request(uri)
    %x{
      var xhr = new __XMLHttpRequest__();
      xhr.open('GET', uri, false);
      xhr.send();
      return xhr;
    }
  end
end
