# frozen_string_literal: true

module Opal
  # WHEN RELEASING:
  # Remember to update RUBY_ENGINE_VERSION in opal/corelib/constants.rb too!
  VERSION = '2.0.0dev'

  # Only major and minor parts of version
  VERSION_MAJOR_MINOR = VERSION.split('.').first(2).join('.').freeze
end
