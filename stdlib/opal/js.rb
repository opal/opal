# backtick_javascript: true

require 'opal/js/base'
require 'opal/js/wrapper'
require 'opal/js/wrapper_dsl'
require 'opal/js/conversion'
require 'opal/js/dispatch'
require 'opal/js/export'

# rubocop:disable Style/GlobalVars
$js = ::Opal::JS.global
# rubocop:enable Style/GlobalVars
