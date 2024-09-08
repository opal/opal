require 'opal-platform'

case OPAL_PLATFORM
when 'nashorn'
  ::Opal.advanced_require 'nashorn', import_condition: 'Opal.OPAL_PLATFORM == "nashorn"'
when 'gjs'
  ::Opal.advanced_require 'gjs', import_condition: 'Opal.OPAL_PLATFORM == "gjs"'
when 'quickjs'
  ::Opal.advanced_require 'quickjs', import_condition: 'Opal.OPAL_PLATFORM == "quickjs"'
when 'deno'
  ::Opal.advanced_require 'deno/base', import_condition: 'Opal.OPAL_PLATFORM == "deno"'
when 'nodejs'
  ::Opal.advanced_require 'nodejs/base', import_condition: 'Opal.OPAL_PLATFORM == "nodejs"'
when 'headless-chrome'
  ::Opal.advanced_require 'headless_browser/base', import_condition: 'Opal.OPAL_PLATFORM == "headless-chrome"'
when 'headless-firefox'
  ::Opal.advanced_require 'headless_browser/base', import_condition: 'Opal.OPAL_PLATFORM == "headless-firefox"'
when 'safari'
  ::Opal.advanced_require 'headless_browser/base', import_condition: 'Opal.OPAL_PLATFORM == "safari"'
when 'opal-miniracer'
  ::Opal.advanced_require 'opal/miniracer', import_condition: 'Opal.OPAL_PLATFORM == "opal-miniracer"'
end
