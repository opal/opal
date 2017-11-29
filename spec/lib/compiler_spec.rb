require 'lib/spec_helper'
require 'support/match_helpers'

RSpec.describe Opal::Compiler do
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
      expect_compiled("def test_method; end").to include("function $$test_method()")
    end

    context "when function name is reserved" do
      it "generates a valid named function for method" do
        expect_compiled("def Array; end").to include("function $$Array()")
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

  describe "extracting __END__ content" do
    shared_examples "it extracts __END__" do |source, expected_eof_content|
      it "extracts #{expected_eof_content.inspect} from #{source.inspect}" do
        compiler = Opal::Compiler.new(source)
        compiler.parse
        expect(compiler.eof_content).to eq(expected_eof_content)
      end
    end

    include_examples "it extracts __END__", "code", nil
    include_examples "it extracts __END__", "code\n__END_", nil
    include_examples "it extracts __END__", "code\n__END__", ""
    include_examples "it extracts __END__", "code\n\n\n__END__", ""
    include_examples "it extracts __END__", "code\n__END__data", nil
    include_examples "it extracts __END__", "code\n__END__\ndata", "data"
    include_examples "it extracts __END__", "code\n__END__\nline1\nline2", "line1\nline2"
    include_examples "it extracts __END__", "code\n__END__\nline1\nline2\n", "line1\nline2\n"
    include_examples "it extracts __END__", "code\n__END__\nline1\nline2\n", "line1\nline2\n"
    include_examples "it extracts __END__", "code\n __END__\ndata", nil
    include_examples "it extracts __END__", "\"multiline string\n__END__\nwith data separator\"\n__END__\ndata", "data"
  end

  describe "DATA special variable" do
    it "is not a special case unless __END__ part present in source" do
      expect_compiled("DATA").to include("DATA")
      expect_compiled("DATA\nMALFORMED__END__").to include("DATA")
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
        compiler = compiler_for(%Q{autoload :Whatever, "#{__FILE__}"})
        expect(compiler.requires).to eq([])
      end

      it 'parses and resolve second #autoload arguments' do
        compiler = compiler_for(%Q{class Foo; autoload :Whatever, "#{__FILE__}"; end})
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
          expect_compiled('foo = 42 if "test" > "bar"').to include('if ($truthy($rb_gt("test", "bar")))')
        end

        it 'specifically == excludes nil check for strings' do
          expect_compiled('foo = 42 if "test" == "bar"').to include("if (\"test\"['$=='](\"bar\"))")
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if bar > 5").to include('if ($truthy($rb_gt(bar, 5)))')
        end

        it 'specifically == excludes nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if bar == 5").to include("if (bar['$=='](5))")
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if Test > 4").to include("if ($truthy($rb_gt(Opal.const_get_relative($nesting, 'Test'), 4))) ")
        end

        it 'specifically == excludes nil check for constants' do
          expect_compiled("foo = 42 if Test == 4").to include("if (Opal.const_get_relative($nesting, 'Test')['$=='](4))")
        end
      end

      context 'without operators' do
        it 'adds nil check for primitives' do
          expect_compiled('foo = 42 if 2').to include('if ($truthy(2))')
          expect_compiled('foo = 42 if 2.5').to include('if ($truthy(2.5))')
          expect_compiled('foo = 42 if true').to include('if ($truthy(true))')
        end

        it 'adds nil check for boolean method calls' do
          expect_compiled('foo = 42 if true.something').to include('if ($truthy(true.$something()))')
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if "test"').to include('if ($truthy("test"))')
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if bar").to include('if ($truthy(bar))')
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if Test").to include("if ($truthy(Opal.const_get_relative($nesting, 'Test')))")
        end
      end
    end

    context 'parentheses' do
      context 'with operators' do
        it 'adds nil check for primitives' do
          expect_compiled('foo = 42 if (2 > 3)').to include('if ($truthy($rb_gt(2, 3))')
          expect_compiled('foo = 42 if (2.5 > 3.5)').to include('if ($truthy($rb_gt(2.5, 3.5))')
          expect_compiled('foo = 42 if (true > false)').to include('if ($truthy($rb_gt(true, false))')

          expect_compiled('foo = 42 if (2 == 3)').to include("if ($truthy((2)['$=='](3))")
          expect_compiled('foo = 42 if (2.5 == 3.5)').to include("if ($truthy((2.5)['$=='](3.5))")
          expect_compiled('foo = 42 if (true == false)').to include("if ($truthy(true['$=='](false)))")
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if ("test" > "bar")').to include('if ($truthy($rb_gt("test", "bar"))')
          expect_compiled('foo = 42 if ("test" == "bar")').to include("if ($truthy(\"test\"['$=='](\"bar\"))")
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if (bar > 5)").to include('if ($truthy($rb_gt(bar, 5))')
          expect_compiled("bar = 4\nfoo = 42 if (bar == 5)").to include("if ($truthy(bar['$=='](5))) ")
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if (Test > 4)").to include("if ($truthy($rb_gt(Opal.const_get_relative($nesting, 'Test'), 4))")
          expect_compiled("foo = 42 if (Test == 4)").to include("if ($truthy(Opal.const_get_relative($nesting, 'Test')['$=='](4))")
        end
      end

      context 'without operators' do
        it 'adds nil check for primitives' do
          expect_compiled('foo = 42 if (2)').to include('if ($truthy(2)')
          expect_compiled('foo = 42 if (2.5)').to include('if ($truthy(2.5)')
          expect_compiled('foo = 42 if (true)').to include('if ($truthy(true)')
        end

        it 'adds nil check for boolean method calls' do
          expect_compiled('foo = 42 if (true.something)').to include('if ($truthy(true.$something())')
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if ("test")').to include('if ($truthy("test")')
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if (bar)").to include('if ($truthy(bar)')
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if (Test)").to include("if ($truthy(Opal.const_get_relative($nesting, 'Test'))")
        end
      end
    end
  end

  describe 'Regexp flags' do
    it 'skips the unsupported ones' do
      expect_compiled("/foobar/nix").to include("/foobar/i")
    end
  end

  describe 'x-strings' do
    it 'removes the trailing semicolon' do
      expect_compiled('a = `1;`').not_to include(";)")
    end
  end

  describe 'magic encoding comment' do
    let(:diagnostics) { [] }

    around(:each) do |e|
      original_diagnostics_consumer = Opal::Parser.diagnostics_consumer
      Opal::Parser.diagnostics_consumer = ->(diagnostic) { diagnostics << diagnostic }
      e.run
      Opal::Parser.diagnostics_consumer = original_diagnostics_consumer
    end

    let(:encoding_comment) { '' }
    let(:string) { '' }

    let(:file) do
      <<-RUBY
        # encoding: #{encoding_comment}
        "#{string}"
      RUBY
    end

    shared_examples 'it compiles the string as' do |expected|
      it "compiles the string as #{expected}" do
        expect_compiled(file).to include(expected)
      end
    end

    shared_examples 'it re-encodes the string using $force_encoding' do
      it 'it re-encodes the string using $force_encoding' do
        expect_compiled(file).to include("$force_encoding")
      end
    end

    shared_examples 'it does not re-encode the string using $force_encoding' do
      it 'it does not re-encode the string using $force_encoding' do
        expect_compiled(file).to_not include("$force_encoding")
      end
    end

    shared_examples 'it does not print any warnings' do
      it 'does not print any warnings' do
        compile(file)
        expect(diagnostics).to eq([])
      end
    end

    context 'utf-8 comment' do
      let(:encoding_comment) { 'utf-8' }

      context 'valid sequence' do
        let(:string) { 'λ' }

        include_examples 'it compiles the string as', 'λ'.inspect
        include_examples 'it does not re-encode the string using $force_encoding'
        include_examples 'it does not print any warnings'
      end

      context 'invalid sequence' do
        let(:string) { "\xFF" }

        it 'raises an error' do
          expect {
            compiled(file)
          }.to raise_error(EncodingError, 'invalid byte sequence in UTF-8')
        end
      end
    end

    context 'ascii-8bit comment' do
      let(:encoding_comment) { 'ascii-8bit' }

      context 'valid sequence' do
        let(:string) { "\xFF" }

        include_examples 'it compiles the string as', '"\xFF".$force_encoding("ASCII-8BIT")'
        include_examples 'it does not print any warnings'
      end

      context 'unicode sequence' do
        let(:string) { 'λ' }

        include_examples 'it compiles the string as', 'λ'.inspect + '.$force_encoding("ASCII-8BIT")'
        include_examples 'it does not print any warnings'
      end
    end
  end

  def compiled(*args)
    Opal::Compiler.new(*args).compile
  end

  alias compile compiled

  def expect_compiled(*args)
    expect(compiled(*args))
  end

  def compiler_for(*args)
    Opal::Compiler.new(*args).tap(&:compile)
  end
end
