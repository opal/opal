require 'lib/spec_helper'

describe Opal::Compiler do
  def expect_compiled(*args)
    expect(Opal::Compiler.new(*args).compile)
  end

  describe "pre-processed if conditions" do
    it "compiles if blocks using RUBY_ENGINE/RUBY_PLATFORM == opal" do
      expect_compiled(<<-RUBY).to include("should_compile_fine")
      if RUBY_ENGINE == 'opal'
        :should_compile_fine
      end
      RUBY

      expect_compiled(<<-RUBY).to include("so_should_this")
      if RUBY_PLATFORM == 'opal'
        :so_should_this
      end
      RUBY
    end

    it "does not compile if blocks using RUBY_ENGINE/RUBY_PLATFORM != opal" do
      expect_compiled(<<-RUBY).to_not include('should_not_compile')
        if RUBY_ENGINE != 'opal'
          :should_not_compile
        end
      RUBY

      expect_compiled(<<-RUBY).to_not include('should_not_compile')
        if RUBY_PLATFORM != 'opal'
          :should_not_compile
        end
      RUBY
    end

    it "skips elsif/else parts for CONST == opal" do
      expect_compiled(<<-RUBY).to_not include("should_be_skipped")
      if RUBY_PLATFORM == "opal"
        :ok
      else
        :should_be_skipped
      end
      RUBY

      result = expect_compiled(<<-RUBY)
      if RUBY_ENGINE == 'opal'
        :this_compiles
      elsif false
        :this_does_not_compile
      else
        :this_neither
      end
      RUBY

      result.to_not include("this_does_not_compile", "this_neither")
    end

    it "generates if-code as normal without check" do
      expect_compiled(<<-RUBY).to include("should_compile", "and_this")
      if some_conditional
        :should_compile
      else
        :and_this
      end
      RUBY
    end
  end

  describe "pre-processed unless conditionals" do
    it "skips over if using RUBY_ENGINE/RUBY_PLATFORM == 'opal'" do
      expect_compiled(<<-RUBY).to_not include("should_not_compile")
      unless RUBY_ENGINE == 'opal'
        :should_not_compile
      end
      RUBY
    end

    it "generates unless code as normal if no check" do
      expect_compiled(<<-RUBY).to include("this_should_compile")
      unless this_is_true
        :this_should_compile
      end
      RUBY
    end
  end
end
