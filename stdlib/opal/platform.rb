require 'opal-platform'

case OPAL_PLATFORM
when 'bun'              then require 'bun'
when 'deno'             then require 'deno'
when 'gjs'              then require 'gjs'
when 'headless-chrome'  then require 'headless_browser/base'
when 'headless-firefox' then require 'headless_browser/base'
when 'nashorn'          then require 'nashorn'
when 'nodejs'           then require 'nodejs'
when 'opal-miniracer'   then require 'opal/miniracer'
when 'quickjs'          then require 'quickjs'
when 'safari'           then require 'headless_browser/base'
end
