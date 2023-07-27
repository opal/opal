class CGI
  module Util
    def escapeURIComponent(c)
      `encodeURI(c)`
    end

    def unescapeURIComponent(c)
      `decodeURI(c)`
    end
  end

  include Util
  extend Util
end
