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
      expect_compiled("true").to include('(function(Opal) {')
      expect_compiled("true").to start_with('Opal.queue(function(Opal) {')
      expect_compiled("true").to end_with("});\n")
    end

    it 'puts the compiled into "Opal.modules"' do
      options = { :requirable => true, :file => "pippo" }
      expect_compiled("true", options).to include('Opal.modules["pippo"] = function(Opal) {')
      expect_compiled("true", options).to end_with("};\n")
    end
  end

  it "should compile simple ruby values" do
    expect_compiled("3.142").to include("return 3.142")
    expect_compiled("123e1").to include("return 1230")
    expect_compiled("123E+10").to include("return 1230000000000")
    expect_compiled("false").to include("return false")
    expect_compiled("true").to include("return true")
    expect_compiled("0;nil").to include("return nil") # NB: Empty nil return is compiled-out
  end

  it "should compile ruby strings" do
    expect_compiled('"hello world"').to include('return "hello world"')
    expect_compiled('"hello #{100}"').to include('"hello "', '100')
  end

  it "should compile ruby strings with escapes" do
    expect_compiled('"hello \e"').to include('\u001b')
    expect_compiled('"hello \e#{nil}"').to include('\u001b')
  end

  it "should compile ruby ranges" do
    expect_compiled('1..1').to include('$range(1, 1, false)')
    expect_compiled('1...1').to include('$range(1, 1, true)')
    expect_compiled('..1').to include('$range(nil, 1, false)')
    expect_compiled('...1').to include('$range(nil, 1, true)')
    expect_compiled('1..').to include('$range(1, nil, false)')
    expect_compiled('1...').to include('$range(1, nil, true)')
    # Following return Opal.range.$new instead of $range. Some also miss a space.
    expect_compiled('nil..1').to include('(nil, 1, false)')
    expect_compiled('nil...1').to include('(nil,1, true)')
    expect_compiled('"a"..nil').to include('("a", nil, false)')
    expect_compiled('"a"...nil').to include('("a",nil, true)')
    expect_compiled('..nil').to include('(nil, nil, false)')
    expect_compiled('...nil').to include('(nil,nil, true)')
  end

  it "should compile method calls" do
    expect_compiled("self.inspect").to include("$inspect()")
    expect_compiled("self.map { |a| a + 10 }").to include("'map'")
  end

  it "adds method missing stubs" do
    expect_compiled("self.puts 'hello'").to include("Opal.add_stubs('puts')")
  end

  it 'adds method missing stubs with operators' do
    expect_compiled("class Foo; end; Foo.new > 5").to include("Opal.add_stubs('>,new')")
  end

  it "should compile constant lookups" do
    expect_compiled("Object").to include("Object")
    expect_compiled("Array").to include("Array")
  end

  it "should compile undef calls" do
    expect_compiled("undef a").to include("$udef(self, '$' + \"a\")")
    expect_compiled("undef a,b").to match(/\$udef\(self, '\$' \+ "a"\);.*\$udef\(self, '\$' \+ "b"\);/m)
  end

  describe "method names" do
    it "generates a named function for method" do
      expect_compiled("def test_method; []; end").to include("function $$test_method()")
    end

    context "when function name is reserved" do
      it "generates a valid named function for method" do
        expect_compiled("def Array; []; end").to include("function $$Array()")
      end
    end

    context "when function name is not valid" do
      it "generates a name in a safe way" do
        expect_compiled("def test_method?; []; end").to include("function $test_method$ques$1()")
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

  describe 'pre-processing require-ish methods' do
    describe '#require' do
      it 'parses and resolve #require argument' do
        compiler = compiler_for(%Q{require "#{__FILE__}"})
        expect(compiler.requires).to eq([__FILE__])
      end
    end

    describe '#autoload' do
      it 'parses and resolve second #autoload arguments in top scope' do
        compiler = compiler_for(%Q{autoload :Whatever, "#{__FILE__}"})
        expect(compiler.requires).to eq([__FILE__])
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
        end

        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if "test" > "bar"').to include('if ($truthy($rb_gt("test", "bar")))')
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if bar > 5").to include('if ($truthy($rb_gt(bar, 5)))')
        end

        it 'adds nil check for constants' do
          expect_compiled("foo = 42 if Test > 4").to include("if ($truthy($rb_gt($$('Test'), 4))) ")
        end

        it 'adds nil check for self' do
          expect_compiled("foo = 42 if self > 4").to include("if ($truthy($rb_gt(self, 4))) ")
        end

        it 'converts each == call inside if to an $eqeq wrapper, which does a truthy check' do
          expect_compiled('foo = 42 if 2 == 3').to include("if ($eqeq(2, 3))")
          expect_compiled('foo = 42 if 2.5 == 3.5').to include("if ($eqeq(2.5, 3.5))")
          expect_compiled('foo = 42 if true == false').to include("if ($eqeq(true, false))")
          expect_compiled('foo = 42 if "test" == "bar"').to include("if ($eqeq(\"test\", \"bar\"))")
          expect_compiled("bar = 4\nfoo = 42 if bar == 5").to include("if ($eqeq(bar, 5))")
          expect_compiled("foo = 42 if Test == 4").to include("if ($eqeq($$('Test'), 4))")
          expect_compiled("bar = 4\nfoo = 42 if bar == 5").to include("if ($eqeq(bar, 5))")
        end

        it "doesn't convert ==/=== calls to $eqeq(eq) wrappers outside of an if" do
          expect_compiled("bar == 5").not_to include("$eqeq(bar, 5)")
        end

        it 'converts each === call inside if to an $eqeqeq wrapper, which does a truthy check' do
          expect_compiled('foo = 42 if 2 === 3').to include("if ($eqeqeq(2, 3))")
          expect_compiled('foo = 42 if 2.5 === 3.5').to include("if ($eqeqeq(2.5, 3.5))")
          expect_compiled('foo = 42 if true === false').to include("if ($eqeqeq(true, false))")
          expect_compiled('foo = 42 if "test" === "bar"').to include("if ($eqeqeq(\"test\", \"bar\"))")
          expect_compiled("bar = 4\nfoo = 42 if bar === 5").to include("if ($eqeqeq(bar, 5))")
          expect_compiled("foo = 42 if Test === 4").to include("if ($eqeqeq($$('Test'), 4))")
          expect_compiled("bar = 4\nfoo = 42 if bar === 5").to include("if ($eqeqeq(bar, 5))")
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
          expect_compiled("foo = 42 if Test").to include("if ($truthy($$('Test')))")
        end
      end
    end

    context 'parentheses' do
      context 'with operators' do
        it 'adds nil check for strings' do
          expect_compiled('foo = 42 if ("test" > "bar")').to include('if ($truthy($rb_gt("test", "bar"))')
        end

        it 'adds nil check for lvars' do
          expect_compiled("bar = 4\nfoo = 42 if (bar > 5)").to include('if ($truthy($rb_gt(bar, 5))')
        end

        it 'converts == expressions to $eqeq checks' do
          expect_compiled('foo = 42 if (2 == 3)').to include("if ($eqeq(2, 3))")
          expect_compiled('foo = 42 if (2.5 == 3.5)').to include("if ($eqeq(2.5, 3.5))")
          expect_compiled('foo = 42 if (true == false)').to include("if ($eqeq(true, false))")
          expect_compiled('foo = 42 if ("test" == "bar")').to include("if ($eqeq(\"test\", \"bar\")")
          expect_compiled("bar = 4\nfoo = 42 if (bar == 5)").to include("if ($eqeq(bar, 5))")
          expect_compiled("foo = 42 if (Test == 4)").to include("if ($eqeq($$('Test'), 4))")
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
          expect_compiled("foo = 42 if (Test)").to include("if ($truthy($$('Test'))")
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
    let(:compiler_options) { {backtick_javascript: true} }

    describe "escapes" do
      it "compiles the exscapes directly as appearing in x-strings" do
        expect_compiled('`"hello\nworld"`').to include('"hello\nworld"')
        expect_compiled('%x{"hello\nworld"}').to include('"hello\nworld"')
      end
    end

    describe 'semicolons handling' do
      def compiling(code, &block)
        compiler = Opal::Compiler.new(code)
        yield compiler
      end

      it "respects JS returns not doubling the trailing semicolon" do
        expect_compiled(%q{
          def foo
            `return bar(baz)`
          end
        }).to include("  return bar(baz);\n")

        expect_compiled(%q{
          def foo
            %x{return bar(baz)}
          end
        }).to include("  return bar(baz);\n")

        expect_compiled(%q{
          def foo
            %x{return bar(baz);}
          end
        }).to include("  return bar(baz);\n")

        expect_compiled(%q{
          def foo
            %x{
              return bar(baz)
            }
          end
        }).to include("  return bar(baz);\n")

        expect_compiled(%q{
          def foo
            %x{
              return bar(baz);
            }
          end
        }).to include("  return bar(baz);\n")

        expect_compiled(%q{
          def foo
            789
            `#{123 + bar} * 456;`
          end
        }).to include("  return $rb_plus(123, self.$bar()) * 456;\n")

        expect_compiled(%q{
          def foo
            789
            `#$bar * 456`
          end
        }).to include("  return $gvars.bar * 456;\n")

        expect_compiled(%q{
          def foo
            789
            `#@bar * 456`
          end
        }).to include("  return self.bar * 456;\n")

        expect_compiled(%q{
          def foo
            789
            `456 * #@bar`
          end
        }).to include("  return 456 * self.bar;\n")

        expect_compiled(%q{
          if `compare === nil`
            raise ArgumentError, "comparison of #{a.class} with #{b.class} failed"
          end
        }).to include("  if ($truthy(compare === nil)) {\n")

        expect_compiled(%q{
          def <<(count)
            count = Opal.coerce_to! count, Integer, :to_int
            `#{count} > 0 ? self << #{count} : self >> -#{count}`
          end
        }).to include("  return count > 0 ? self << count : self >> -count;\n")

        expect_compiled(%q{
          def self.exist? path
            path = path.path if path.respond_to? :path
            `return executeIOAction(function(){return __fs__.existsSync(#{path})})`
          end
        }).to include("  return executeIOAction(function(){return __fs__.existsSync(path)});\n")

        expect_compiled(%q{
          def self.exist? path
            path = path.path if path.respond_to? :path
            `executeIOAction(function(){return __fs__.existsSync(#{path})})`
          end
        }).to include("  return executeIOAction(function(){return __fs__.existsSync(path)});\n")

        expect_compiled(%q{
          def self.exist? path
            path = path.path if path.respond_to? :path
            `return executeIOAction(function(){return __fs__.existsSync(#{path})});`
          end
        }).to include("  return executeIOAction(function(){return __fs__.existsSync(path)});\n")

        expect_compiled(%q{
          def self.exist? path
            path = path.path if path.respond_to? :path
            `executeIOAction(function(){return __fs__.existsSync(#{path})});`
          end
        }).to include("  return executeIOAction(function(){return __fs__.existsSync(path)});\n")
      end

      it 'warns if a semicolon is used in a single line' do
        expect_number_of_warnings(%{a = `1;`}).to              eq(1)
        expect_number_of_warnings(%{a = `1;`; return}).to      eq(1)
        expect_number_of_warnings(%{a = `1;`}).to              eq(1)
        expect_number_of_warnings(%{a = ` 1; `}).to            eq(1)
        expect_number_of_warnings(%{a = %x{\n 1; \n}}).to      eq(1)
        expect_number_of_warnings(%{def foo; ` 1;  `; end}).to eq(1)
      end

      it 'does not warn for statements' do
        expect_number_of_warnings(%{`foo;`; return}).to        eq(0)
        expect_number_of_warnings(%{`foo;`; 123}).to           eq(0)
      end

      it 'does not warn for multiline x-strings' do
        expect_number_of_warnings(%{a = `1;\n2;`}).to          eq(0)
        expect_number_of_warnings(%{a = `1;\n2;3; `}).to       eq(0)
        expect_number_of_warnings(%{def foo;` 1;\n  `;end}).to eq(1)
      end
    end

    specify 'when empty' do
      expect_compiled(%q{
        %x{
        }
      }).to include("return nil\n")

      expect_compiled(%q{
        %x{}
      }).to include("return nil\n")

      expect_compiled(%q{
        `

        `
      }).to include("return nil\n")

      expect_compiled(%q{
        ``
      }).to include("return nil\n")
    end

    def expect_number_of_warnings(code, options = compiler_options)
      options = options.merge(eval: true)
      warnings_number = 0
      compiler = Opal::Compiler.new(code, options)
      allow(compiler).to receive(:warning) { warnings_number += 1 }
      compiler.compile
      expect(warnings_number)
    end
  end

  describe '#magic_comments' do
    def expect_magic_comments_for(*lines)
      expect(compiler_for(lines.join("\n")).magic_comments)
    end

    it 'extracts them in a hash' do
      expect_magic_comments_for("").to eq({})

      expect_magic_comments_for(
        "",
        "#     foo:true",
        "",
        "",
        "",
        "#bar : false",
        "#baz  :qux",
        "#biz  :boz",
        "baz",
      ).to eq(
        foo: true,
        bar: false,
        baz: "qux",
        biz: "boz"
      )

      expect_magic_comments_for(
        "#baz  :qux",
        "#biz  :boz",
        "",
        "baz",
      ).to eq(
        baz: "qux",
        biz: "boz"
      )

      expect_magic_comments_for(
        "#-*- baz  :qux-*-",
        "#   -*-biz  :boz   -*-   ",
      ).to eq(
        baz: "qux",
        biz: "boz"
      )
    end

    it 'accepts complex values' do
      expect_magic_comments_for("").to eq({})

      expect_magic_comments_for(
        "#baz:  qux,naz!",
        "#biz : boz?  ,bux,   []=",
        "#buz  :<<,+,!@",
      ).to eq(
        baz: "qux,naz!",
        biz: "boz?  ,bux,   []=",
        buz: "<<,+,!@",
      )
    end
  end

  describe 'magic encoding comment' do
    let(:diagnostics) { [] }

    around(:each) do |e|
      original_diagnostics_consumer = Opal::Parser.default_parser_class.diagnostics_consumer
      Opal::Parser.default_parser_class.diagnostics_consumer = ->(diagnostic) { diagnostics << diagnostic }
      e.run
      Opal::Parser.default_parser_class.diagnostics_consumer = original_diagnostics_consumer
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

        include_examples 'it compiles the string as', '$str("\xFF","ASCII-8BIT")'
        include_examples 'it does not print any warnings'
      end

      context 'unicode sequence' do
        let(:string) { 'λ' }
        encoded_string = 'λ'.force_encoding("ascii-8bit")

        include_examples 'it compiles the string as', "$str(#{encoded_string.inspect},\"ASCII-8BIT\")"
        include_examples 'it does not print any warnings'
      end
    end
  end

  describe 'a compilation error' do
    context 'at compile time' do
      it 'adds the file and line to the backtrace' do
        error = nil
        begin
          compiled('BEGIN {}', file: "#{File.basename(__FILE__)}/foobar.js.rb")
        rescue Opal::SyntaxError => syntax_error
          error = syntax_error
        end

        expect(error.backtrace[0]).to eq("#{File.basename(__FILE__)}/foobar.js.rb:in `BEGIN {}'")
        expect(compiler_backtrace(error)[0]).to match(/:in [`'](?:Opal::Compiler#)?error[`']$/)
        expect(compiler_backtrace(error)[-4]).to match(/:in [`']block in (?:Opal::Compiler#)?fragments[`']$/)
        expect(compiler_backtrace(error)[-1]).to match(/:in [`'](?:Opal::Compiler#)?compile[`']$/)
        expect(error.backtrace.size).to be > 1
      end
    end

    context 'at parse time' do
      it 'adds the file and line to the backtrace' do
        error = nil

        begin
          parsed('def foo', file: "#{File.basename(__FILE__)}/foobar.js.rb")
        rescue Opal::SyntaxError => syntax_error
          error = syntax_error
        end
        expect(error.backtrace[0]).to eq("#{File.basename(__FILE__)}/foobar.js.rb:1:in `def foo'")
        expect(compiler_backtrace(error)[0]).to match(/:in [`']block in (?:Opal::Compiler#)?parse[`']$/)
        expect(error.backtrace.size).to be > 1

        expect($diagnostic_messages.flatten).to eq([
          "#{File.basename(__FILE__)}/foobar.js.rb:1:8: error: unexpected token $end",
          "#{File.basename(__FILE__)}/foobar.js.rb:1: def foo",
          "#{File.basename(__FILE__)}/foobar.js.rb:1:        ",
        ])
      end
    end

    def compiler_backtrace(error)
      error.backtrace.grep(%r{lib/opal/compiler\.rb})
    end
  end

  describe '[regressions]' do
    it 'accepts empty rescue within while loop' do
      # found running bm_vm1_rescue.rb
      # was raising: NoMethodError: undefined method `type' for nil:NilClass
      expect{
        compiled <<-RUBY
          while foo
            begin
            rescue
            end
          end
        RUBY
      }.not_to raise_error
    end

    it 'accepts a comment as the sole body of a for loop' do
      expect{
        compiled <<-RUBY
          for foo in bar
            #
          end
        RUBY
      }.not_to raise_error
    end
  end

  describe 'bigint_integers option' do
    let(:compiler_options) { {backtick_javascript: true, bigint_integers: true} }

    it 'transforms integer literals in x-strings to BigInt' do
      expect(compiled('`return 42`')).to include('return 42n')
    end

    it 'transforms hex, octal, and binary literals' do
      code = '`return 0xFF + 0o77 + 0b1010`'
      result = compiled(code)
      expect(result).to include('0xFFn')
      expect(result).to include('0o77n')
      expect(result).to include('0b1010n')
    end

    it 'leaves float literals unchanged' do
      result = compiled('`return 3.14`')
      expect(result).to include('3.14')
      expect(result).not_to include('3.14n')
    end

    it 'does not double-transform already BigInt literals' do
      result = compiled('`return 123n`')
      expect(result).to include('123n')
      expect(result).not_to include('123nn')
    end

    it 'transforms integers in complex expressions' do
      code = '`var x = 10 + 20 * 30`'
      result = compiled(code)
      expect(result).to include('10n')
      expect(result).to include('20n')
      expect(result).to include('30n')
    end

    it 'transforms integers in multiline x-strings' do
      code = <<~RUBY
        %x{
          if (self === 0) {
            return 42;
          }
        }
      RUBY
      result = compiled(code)
      expect(result).to include('0n')
      expect(result).to include('42n')
    end
  end

  def compiler_options
    {}
  end

  def compiled(code, options = compiler_options)
    compiler = Opal::Compiler.new(code, options)
    @compiler_warnings = []
    allow(compiler).to receive(:warning) { |*args| @compiler_warnings << args }
    compiler.compile
  end

  def parsed(code, options = compiler_options)
    Opal::Compiler.new(code, options).parse
  end

  alias compile compiled

  def expect_compiled(code, options = compiler_options)
    expect(compiled(code, options))
  end

  def compiler_for(code, options = compiler_options)
    Opal::Compiler.new(code, options).tap(&:compile)
  end
end
