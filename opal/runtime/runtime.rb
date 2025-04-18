require 'runtime/boot'

require 'runtime/platform_support' # must be first
require 'runtime/platforms/browsers'
# require 'runtime/platforms/gjs_compatible'
require 'runtime/platforms/mini_racer'
require 'runtime/platforms/node_compatible'
require 'runtime/platforms/quickjs'
require 'runtime/platforms/unknown' # must be last

require 'runtime/variables'
require 'runtime/exception'

require 'runtime/freeze'
require 'runtime/op_helpers'
require 'runtime/method_missing'

require 'runtime/const'
require 'runtime/module'
require 'runtime/class'
require 'runtime/method'
require 'runtime/proc'
require 'runtime/send'

require 'runtime/array'
require 'runtime/hash'
require 'runtime/string'
require 'runtime/regexp'

require 'runtime/bridge'

require 'runtime/misc'
require 'runtime/dir_file_io'

require 'runtime/helpers'
