require 'opal-platform'

case OPAL_PLATFORM
when 'nashorn'          then require 'nashorn'
when 'gjs'              then require 'gjs'
when 'quickjs'          then require 'quickjs'
when 'deno'             then require 'deno/base'
when 'nodejs'           then require 'nodejs/base'
when 'node-cdp'         then require 'nodejs/base'
when 'headless-chrome'  then require 'headless_browser'
when 'headless-firefox' then require 'headless_browser'
when 'opal-miniracer'   then require 'opal/miniracer'
end
