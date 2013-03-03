require 'opal'
require 'opal-parser'

# stdlib
require 'opal/date'
require 'opal/enumerator'

##
# opal_spec

# opal_spec = true
# require 'opal-spec'

##
# mspec

opal_spec = false
require 'mspec'

module Kernel
  def opal_eval(str)
    code = Opal::Parser.new.parse str
    `eval(code)`
  end

  def opal_parse(str, file='(string)')
    Opal::Grammar.new.parse str, file
  end

  def opal_eval_compiled(javascript)
    `eval(javascript)`
  end

  def eval(str)
    opal_eval str
  end
end

# Only run when using opal-spec
if opal_spec
  module OpalTest
    class RaiseErrorMatcher
      def not_match(block)
        should_raise = false
        begin
          block.call
        rescue => e
          should_raise = true
        end

        if should_raise
          failure "did not expect #{@actual} to be raised."
        end
      end
    end

    class RespondToMatcher
      def not_match(actual)
        if actual.respond_to?(@expected)
          failure "Expected #{actual.inspect} (#{actual.class}) not to respond to #{@expected}"
        end
      end
    end

    class TestCase
      def self.ruby_bug(*args, &block)
        block.call
      end
    end
  end

  module Kernel
    def raise_error expected = Exception, msg = nil
      OpalTest::RaiseErrorMatcher.new expected
    end

    def be_an_instance_of(cls)
      be_kind_of cls
    end
  end

  module Kernel
    def ruby_version_is(version, &block)
      if String === version
        block.call if version == "1.9"
      elsif Range === version
        block.call if version === "1.9"
      end
    end

    def enumerator_class
      Enumerator
    end
  end
else
  module Kernel
    # FIXME: remove
    def ruby_version_is(*); end
    def pending(*); end
  end
end
