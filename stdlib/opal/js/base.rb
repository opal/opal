# backtick_javascript: true

require 'promise/v2'

module ::Opal
  module Export
  end

  module JS
    class ConversionError < ::TypeError; end
  end
end
