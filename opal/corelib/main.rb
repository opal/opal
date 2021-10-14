# use_strict: true
# frozen_string_literal: true

def self.to_s
  'main'
end

def self.include(mod)
  Object.include mod
end

# Compiler overrides this method
def self.using(mod)
  raise 'main.using is permitted only at toplevel'
end
