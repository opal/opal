require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/opal_engine_check'

RSpec.describe Opal::Rewriters::OpalEngineCheck do
  include RewritersHelper
  extend  RewritersHelper

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with basic ==
    if RUBY_ENGINE == 'opal'
      'yes'
    end
  RUBY
    'yes'
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with basic !=
    if RUBY_ENGINE != 'opal'
      'no'
    end
  RUBY
    nil
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with unless
    unless RUBY_ENGINE == 'opal'
      'no'
    end
  RUBY
    nil
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with single line unless
    'no' unless RUBY_ENGINE == 'opal'
  RUBY
    nil
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with basic binary IFs
    if RUBY_ENGINE == 'opal'
      true
    else
      false
    end
  RUBY
    true
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It preserves variables
    if RUBY_ENGINE != 'opal'
      y = 5
      test
      y = 3
      x = 54
    end
  RUBY
    if false
      y = nil
      x = nil
    end
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It removes the test
    if RUBY_ENGINE == 'opal'
      a = 5
      b = 6
    end
  RUBY
    a = 5
    b = 6
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with case expressions
    case RUBY_ENGINE
    when "opal"
      a = 5
    when "ruby"
      a = 7
    when "jruby"
      a = 1
    end
  RUBY
    if false
      a = nil
    end
    a = 5
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with ORs (check for opal must happen first)
    if RUBY_ENGINE == 'opal' || something
      a = 5
    end
  RUBY
    a = 5
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with ANDs (check for opal must happen first)
    if RUBY_ENGINE == 'opal' && something
      a = 5
    end
  RUBY
    if something
      a = 5
    end
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with boolean OR
    RUBY_ENGINE == 'opal' || something
  RUBY
    true
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with boolean AND
    RUBY_ENGINE == 'opal' && something
  RUBY
    something
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with advanced case expressions
    case RUBY_ENGINE
    when "ruby", "jruby", "opal", "rubinius"
      "ruby"
    when "python", "pypy"
      "python"
    when "javascript", "typescript"
      "javascript"
    end
  RUBY
    "ruby"
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It works with nested expressions (and with RUBY_PLATFORM)
    if RUBY_ENGINE == 'opal'
      if RUBY_PLATFORM == 'opal'
        "hello"
      end
    end
  RUBY
    "hello"
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # While preserving variables, it stops at the scope level
    if RUBY_ENGINE != 'opal'
      def test
        a = 5
      end

      class Test
        b = 6
      end

      d = 7

      5.times { c = 6 }
    end
  RUBY
    if false
      d = nil
    end
  RUBY

  include_examples 'it rewrites source-to-AST', <<~RUBY, parse(<<~RUBY)
    # It doesn't rewrite the less obvious cases
    if RUBY_ENGINE == (s = 'opal')
      if (t = RUBY_PLATFORM == 'opal')
        "hello"
      end
    end
  RUBY
    if RUBY_ENGINE == (s = 'opal')
      if (t = RUBY_PLATFORM == 'opal')
        "hello"
      end
    end
  RUBY
end
