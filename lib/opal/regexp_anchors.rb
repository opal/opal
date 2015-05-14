module Opal
  REGEXP_START = RUBY_ENGINE == 'opal' ? '^' : '\A'.freeze
  REGEXP_END = RUBY_ENGINE == 'opal' ? '$' : '\z'.freeze 
end

