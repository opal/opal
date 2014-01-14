require 'template'

class ERB
  module Util
    `var escapes = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'};`
    `var escape_regexp = /[&<>"']/g;`

    def html_escape(str)
      `return ("" + str).replace(escape_regexp, function (m) { return escapes[m] });`
    end

    alias h html_escape
    module_function :h
    module_function :html_escape
  end
end
