require_relative 'file61'

# There's a circular require between file63 and 62
# file62 should be in output file before 63
require 'fixtures/build_order/file63'
require_relative './file62'

require 'fixtures/build_order/file64.rb'

FILE_6 = true
