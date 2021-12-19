require 'opal-platform'

case OPAL_PLATFORM
when 'nashorn'         then require 'nashorn'
when 'gjs'             then require 'gjs'
when 'quickjs'         then require 'quickjs'
when 'nodejs'          then require 'nodejs/base'
when 'headless-chrome' then require 'headless_chrome'
when 'opal-miniracer'  then require 'opal/miniracer'
end
