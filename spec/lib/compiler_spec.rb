require 'lib/spec_helper'
require 'support/match_helpers'

describe Opal::Compiler do
  describe 'regexp' do
    it 'should escape regexp' do
      expect_compiled("%r{^/{4,}$}").to include('/^\/{4,}$/')
      expect_compiled('/\\\\"/').to include('/\\\\"/')
    end
  end

  describe 'requiring' do
    it 'calls #require' do
      expect_compiled("require 'pippo'").to include('self.$require("pippo")')
    end
  end

  describe 'requirable' do
    it 'executes the file' do
      expect_compiled("").to include('(function(Opal) {')
      expect_compiled("").to end_with("})(Opal);\n")
    end

    it 'puts the compiled into "Opal.modules"' do
      options = { :requirable => true, :file => "pippo" }
      expect_compiled("", options).to include('Opal.modules["pippo"] = function(Opal) {')
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

  it "adds method missing stubs" do
    expect_compiled("self.puts 'hello'").to include("Opal.add_stubs(['$puts'])")
  end

  it 'adds method missing stubs with operators' do
    expect_compiled("class Foo; end; Foo.new > 5").to include("Opal.add_stubs(['$>', '$new'])")
  end

  it "should compile constant lookups" do
    expect_compiled("Object").to include("Object")
    expect_compiled("Array").to include("Array")
  end

  it "should compile undef calls" do
    expect_compiled("undef a").to include("Opal.udef(self, '$' + \"a\")")
    expect_compiled("undef a,b").to match(/Opal.udef\(self, '\$' \+ "a"\);.*Opal.udef\(self, '\$' \+ "b"\);/m)
  end

  describe "class names" do
    it "generates a named function for class using $ prefix" do
      expect_compiled("class Foo; end").to include("function $Foo")
    end
  end

  describe "method names" do
    it "generates a named function for method" do
      expect_compiled("def test_method; end").to include("function ːtest_method()")
    end

    context "when function name is reserved" do
      it "generates a valid named function for method" do
        expect_compiled("def Array; end").to include("function ːArray()")
      end
    end

    context "when function name is not valid" do
      it "skips generating a name" do
        expect_compiled("def test_method?; end").to include("function()")
      end
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

    describe 'pre-processing require-ish methods' do
    describe '#require' do
      it 'parses and resolve #require argument' do
        compiler = compiler_for(%Q{require "#{__FILE__}"})
        expect(compiler.requires).to eq([__FILE__])
      end
    end

    describe '#autoload' do
      it 'ignores autoload outside of context class' do
        compiler = compiler_for(%Q{autoload Whatever, "#{__FILE__}"})
        expect(compiler.requires).to eq([])
      end

      it 'parses and resolve second #autoload arguments' do
        compiler = compiler_for(%Q{class Foo; autoload Whatever, "#{__FILE__}"; end})
        expect(compiler.requires).to eq([__FILE__])
      end
    end

    describe '#require_relative' do
      it 'parses and resolve #require_relative argument' do
        compiler = compiler_for(%Q{require_relative "./#{File.basename(__FILE__)}"}, file: __FILE__)
        expect(compiler.requires).to eq([__FILE__])
      end
    end

    describe '#require_tree' do
      require 'pathname'

      it 'parses and resolve #require argument' do
        file = Pathname(__FILE__).join('../fixtures/require_tree_test.rb')

        compiler = compiler_for(file.read)
        expect(compiler.required_trees).to eq(['../fixtures/required_tree_test'])
      end
    end
  end

  describe 'truthy check' do
    context 'no parentheses' do
      context 'with operators' do
        it 'excludes nil check for primitives' do
          expect_compiled('foo = 42 if 2 > 3').to include('if ($rb_gt(2, 3))')
          expect_compiled('foo = 42 if 2.5 > 3.5').to include('if ($rb_gt(2.5, 3.5))')
          expect_compiled('foo = 42 if true > false').to include('if ($rb_gt(true, false))')

          expect_compiled('foo = 42 if 2 == 3').to include("if ((2)['$=='](3))")
          expect_compiled('foo = 42 if 2.5 == 3.5').to include("if ((2.5)['$=='](3.5))")
          expect_compiled('foo = 42 if true == false').to include("if (true['$=='](false))")
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if "test" > "bar"').to include('if ((($a = $rb_gt("test", "bar")) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'specifically == excludes nil check for strings' do
          expect_compiled('foo = 42 if "test" == "bar"').to include("if (\"test\"['$=='](\"bar\"))")
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if bar > 5").to include('if ((($a = $rb_gt(bar, 5)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'specifically == excludes nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if bar == 5").to include("if (bar['$=='](5))")
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if Test > 4").to include("if ((($a = $rb_gt($scope.get('Test'), 4)) !== nil && $a != null && (!$a.$$is_boolean || $a == true))) ")
        end

        it 'specifically == excludes nil check for constants' do
          expect_compiled("foo = 42 if Test == 4").to include("if ($scope.get('Test')['$=='](4))")
        end
      end

      context 'without operators' do
        it 'adds nil check for primitives' do
          expect_compiled('foo = 42 if 2').to include('if ((($a = 2) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled('foo = 42 if 2.5').to include('if ((($a = 2.5) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled('foo = 42 if true').to include('if ((($a = true) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'adds nil check for boolean method calls' do
          expect_compiled('foo = 42 if true.something').to include('if ((($a = true.$something()) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if "test"').to include('if ((($a = "test") !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if bar").to include('if (bar !== false && bar !== nil && bar != null)')
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if Test").to include("if ((($a = $scope.get('Test')) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
        end
      end
    end

    context 'parentheses' do
      context 'with operators' do
        it 'adds nil check for primitives' do
          expect_compiled('foo = 42 if (2 > 3)').to include('if ((($a = $rb_gt(2, 3)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled('foo = 42 if (2.5 > 3.5)').to include('if ((($a = $rb_gt(2.5, 3.5)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled('foo = 42 if (true > false)').to include('if ((($a = $rb_gt(true, false)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')

          expect_compiled('foo = 42 if (2 == 3)').to include("if ((($a = (2)['$=='](3)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
          expect_compiled('foo = 42 if (2.5 == 3.5)').to include("if ((($a = (2.5)['$=='](3.5)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
          expect_compiled('foo = 42 if (true == false)').to include("if ((($a = true['$=='](false)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if ("test" > "bar")').to include('if ((($a = $rb_gt("test", "bar")) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled('foo = 42 if ("test" == "bar")').to include("if ((($a = \"test\"['$=='](\"bar\")) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if (bar > 5)").to include('if ((($a = $rb_gt(bar, 5)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled("bar = 4\nfoo = 42 if (bar == 5)").to include("if ((($a = bar['$=='](5)) !== nil && $a != null && (!$a.$$is_boolean || $a == true))) ")
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if (Test > 4)").to include("if ((($a = $rb_gt($scope.get('Test'), 4)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
          expect_compiled("foo = 42 if (Test == 4)").to include("if ((($a = $scope.get('Test')['$=='](4)) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
        end
      end

      context 'without operators' do
        it 'adds nil check for primitives' do
          expect_compiled('foo = 42 if (2)').to include('if ((($a = 2) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled('foo = 42 if (2.5)').to include('if ((($a = 2.5) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
          expect_compiled('foo = 42 if (true)').to include('if ((($a = true) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'adds nil check for boolean method calls' do
          expect_compiled('foo = 42 if (true.something)').to include('if ((($a = true.$something()) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if ("test")').to include('if ((($a = "test") !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if (bar)").to include('if ((($a = bar) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))')
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if (Test)").to include("if ((($a = $scope.get('Test')) !== nil && $a != null && (!$a.$$is_boolean || $a == true)))")
        end
      end
    end
  end

  def expect_compiled(*args)
    expect(Opal::Compiler.new(*args).compile)
  end

  def compiler_for(*args)
    Opal::Compiler.new(*args).tap(&:compile)
  end
end
