def self.to_s
  'main'
end

def self.include(mod)
  ::Object.include mod
end

def self.autoload(*args)
  ::Object.autoload(*args)
end

# Compiler overrides this method
def self.using(mod)
  ::Kernel.raise 'main.using is permitted only at toplevel'
end
