# regexp matches
$~ = nil

$/ = "\n"

RUBY_ENGINE   = 'opal'
RUBY_PLATFORM = 'opal'
RUBY_VERSION  = '1.9.2'
OPAL_VERSION  = `__opal.version`

def to_s
  'main'
end

def include(mod)
  Object.include mod
end