# backtick_javascript: true

require 'corelib/string/encoding'

# these encodings are required for some ruby specs, make them dummy for now
# their existence is often enough, like specs checking if a method returns
# a new string in the same encoding it was orginally encoded in
::Encoding.register 'IBM437', inherits: ::Encoding::UTF_16LE, dummy: true
::Encoding.register 'IBM720', inherits: ::Encoding::UTF_16LE, dummy: true
::Encoding.register 'ISO-8859-15', inherits: ::Encoding::UTF_16LE, dummy: true
::Encoding.register 'ISO-8859-5', inherits: ::Encoding::UTF_16LE, dummy: true
::Encoding.register 'Windows-1251', aliases: ['WINDOWS-1251'], inherits: ::Encoding::UTF_16LE, dummy: true
