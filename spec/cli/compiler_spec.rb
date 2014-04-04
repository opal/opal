require 'cli/spec_helper'

describe Opal::Compiler do
  describe 'requiring' do
    it 'calls #require' do
      expect_compiled("require 'pippo'").to include('self.$require("pippo")')
    end
  end

  describe 'requirable' do
    it 'executes the file' do
      expect_compiled("").to include('(function($opal) {')
      expect_compiled("").to end_with("})(Opal);\n")
    end

    it 'puts the compiled into "Opal.modules"' do
      options = { :requirable => true, :file => "pippo" }
      expect_compiled("", options).to include('Opal.modules["pippo"] = function($opal) {')
      expect_compiled("", options).to end_with("};\n")
    end
  end

  it "should compile simple ruby values" do
    expect_compiled("3.142").to include("return 3.142")
    expect_compiled("123e1").to include("return 1230")
    expect_compiled("123E+10").to include("return 1230000000000")
    expect_compiled("false").to include("return false")
    expect_compiled("true").to include("return true")
    expect_compiled("nil").to include("return nil")
  end

  it "should compile ruby strings" do
    expect_compiled('"hello world"').to include('return "hello world"')
    expect_compiled('"hello #{100}"').to include('"hello "', '100')
  end

  it "should compile method calls" do
    expect_compiled("self.inspect").to include("$inspect()")
    expect_compiled("self.map { |a| a + 10 }").to include("$map")
  end

  it "should compile constant lookups" do
    expect_compiled("Object").to include("scope.Object")
    expect_compiled("Array").to include("scope.Array")
  end

  describe "class names" do
    it "generates a named function for class using $ prefix" do
      expect_compiled("class Foo; end").to include("function $Foo")
    end
  end

  describe "debugger special method" do
    it "generates debugger keyword in javascript" do
      expect_compiled("debugger").to include("debugger")
      expect_compiled("debugger").to_not include("$debugger")
    end
  end

  describe "DATA special variable" do
    it "is not a special case unless __END__ part present in source" do
      expect_compiled("DATA").to include("DATA")
      expect_compiled("DATA\n__END__").to_not include("DATA")
    end

    it "DATA gets compiled as a reference to special $__END__ variable" do
      expect_compiled("a = DATA\n__END__").to include("a = $__END__")
    end

    it "causes the compiler to create a reference to special __END__ variable" do
      expect_compiled("DATA\n__END__\nFord Perfect").to include("$__END__ = ")
    end

    it "does not create a reference to __END__ vairbale unless __END__ content present" do
      expect_compiled("DATA").to_not include("$__END__ = ")
    end
  end

  describe "escapes in x-strings" do
    it "compiles the exscapes directly as appearing in x-strings" do
      expect_compiled('`"hello\nworld"`').to include('"hello\nworld"')
      expect_compiled('%x{"hello\nworld"}').to include('"hello\nworld"')
    end
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

    it "skips elsif/else parts" do
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

  def expect_compiled(*args)
    expect(Opal::Compiler.new.compile *args)
  end
end
