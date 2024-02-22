# backtick_javascript: true

require 'opal/raw'

warn '[Opal] JS module has been renamed to Opal::Raw and will change semantics in Opal 2.1. ' \
     'In addition, you will need to require "opal/raw" instead of "js". ' \
     'To ensure forward compatibility, please update your calls.'

module JS
  extend Opal::Raw
  include Opal::Raw
end
