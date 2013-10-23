require 'runtime'
require 'module'
require 'class'
require 'basic_object'
require 'kernel'
require 'nil_class'
require 'boolean'
require 'error'
require 'regexp'
require 'comparable'
require 'enumerable'
require 'enumerator'
require 'array'
require 'hash'
require 'string'
require 'match_data'
require 'encoding'
require 'numeric'
require 'proc'
require 'range'
require 'time'
require 'struct'
require 'native'
require 'io'

# regexp matches
$& = $~ = $` = $' = nil

# stub library path
$:            = []

# split lines
$/            = "\n"
$,            = " "

# native global
$$ = $global = Native(`Opal.global`)

ARGV          = []
ARGF          = Object.new
ENV           = {}
TRUE          = true
FALSE         = false
NIL           = nil

STDERR        = $stderr = IO.new
STDIN         = $stdin  = IO.new
STDOUT        = $stdout = IO.new

def $stdout.puts(*strs)
  %x{
    for (var i = 0; i < strs.length; i++) {
      if(strs[i] instanceof Array) {
        #{ puts(*`strs[i]`) }
      } else {
        console.log(#{`strs[i]`.to_s});
      }
    }
  }
  nil
end

RUBY_PLATFORM = 'opal'
RUBY_ENGINE   = 'opal'
RUBY_VERSION  = '1.9.3'
RUBY_ENGINE_VERSION = '0.4.4'
RUBY_RELEASE_DATE = '2013-08-13'

def self.to_s
  'main'
end

def self.include(mod)
  Object.include mod
end
