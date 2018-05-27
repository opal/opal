require 'lib/spec_helper'

RSpec.describe Opal::Compiler do
  let(:compiler) { Opal::Compiler.new(method) }

  subject(:compiled) { compiler.compile }

  describe 'defined' do
    let(:method) do
      <<-CODE
      def some_method
        defined? super()
      end
      CODE
    end

    context 'outside block' do
      context 'method missing on' do
        it { is_expected.to include "return ((self, Opal.find_super_dispatcher(self, 'some_method', TMP_some_method_1, true)) != null ? \"super\" : nil)" }
      end

      context 'method missing off' do
        let(:compiler) { Opal::Compiler.new(method, method_missing: false) }

        it { is_expected.to include "return ((self, Opal.find_super_dispatcher(self, 'some_method', TMP_some_method_1, true)) != null ? \"super\" : nil)" }
      end
    end

    context 'inside block' do
      context 'implicit' do
        let(:method) { 'lambda { defined? super }' }

        it { is_expected.to include "return ((self, Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null), true, false)) != null ? \"super\" : nil)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1))" }
      end

      context 'explicit' do
        let(:method) { 'lambda { defined? super() }' }

        it { is_expected.to include "return ((self, Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null), true, false)) != null ? \"super\" : nil)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1))" }
      end
    end
  end

  describe 'call' do
    context 'regular method' do
      context 'formal parameters with splat' do
        context 'and block with actual params of' do
          let(:method) do
            <<-CODE
            def some_method(*stuff, &block2)
              #{invocation}
            end
            CODE
          end

          context 'splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method(*stuff) {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return $send(self, 'call_method', Opal.to_a(stuff), (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method(*stuff, &block2)' }

                it { is_expected.to include "return $send(self, 'call_method', Opal.to_a(stuff), block2.$to_proc())" }
              end
            end
          end

          context 'no splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return $send(self, 'call_method', [], (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method(&block2)' }

                it { is_expected.to include "return $send(self, 'call_method', [], block2.$to_proc())" }
              end
            end
          end
        end

        context 'actual params of' do
          let(:method) do
            <<-CODE
            def some_method(*stuff)
              #{invocation}
            end
            CODE
          end

          context 'splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method(*stuff) {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return $send(self, 'call_method', Opal.to_a(stuff), (TMP_1 = function(a){var self = TMP_1.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method(*stuff, &block2)' }

                it { is_expected.to include "return $send(self, 'call_method', Opal.to_a(stuff), self.$block2().$to_proc())" }
              end
            end
          end

          context 'no splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return $send(self, 'call_method', [], (TMP_1 = function(a){var self = TMP_1.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method(&block2)' }

                it { is_expected.to include "return $send(self, 'call_method', [], self.$block2().$to_proc())" }
              end
            end
          end
        end
      end

      context 'no formal parameters with actual params of' do
        let(:method) do
          <<-CODE
          def regular_method
            #{invocation}
          end
          CODE
        end

        context 'no splat' do
          let(:invocation) { 'another_method(42)' }

          it { is_expected.to include 'return self.$another_method(42)' }
        end

        context 'splat' do
          context 'with no block' do
            let(:invocation) { 'another_method(*args)' }

            it { is_expected.to include "return $send(self, 'another_method', Opal.to_a(self.$args()))" }
          end

          context 'with block' do
            context 'via variable' do
              let(:invocation) { 'another_method(*args) {|b| foobar }' }

              it do
                is_expected.to include <<-CODE
    return $send(self, 'another_method', Opal.to_a(self.$args()), (TMP_1 = function(b){var self = TMP_1.$$s || this;
if (b == null) b = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1))
                CODE
              end
            end

            context 'via reference' do
              let(:invocation) { 'another_method(*args, &block2)' }

              it { is_expected.to include "return $send(self, 'another_method', Opal.to_a(self.$args()), self.$block2().$to_proc())" }
            end
          end
        end

        context 'block' do
          context 'via variable' do
            let(:invocation) { 'another_method {|b| foobar }' }

            it do
              is_expected.to include <<-CODE
    return $send(self, 'another_method', [], (TMP_1 = function(b){var self = TMP_1.$$s || this;
if (b == null) b = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1))
              CODE
            end
          end

          context 'via reference' do
            let(:invocation) { 'another_method(&block)' }

            it { is_expected.to include "return $send(self, 'another_method', [], self.$block().$to_proc())" }
          end
        end
      end
    end

    context 'super' do
      context 'normal method' do
        context 'formal parameters' do
          context 'without splat' do
            let(:method) do
              <<-CODE
              class Foobar
                def some_method(foo, bar)
                  #{invocation}
                end
              end
              CODE
            end

            context 'no arguments' do
              let(:invocation) { 'super()' }

              it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), [], null)" }
            end

            context 'implicit arguments' do
              let(:invocation) { 'super' }

              context 'no block' do
                it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), $zuper, $iter)" }
              end

              context 'block' do
                let(:method) do
                  <<-CODE
                  class Foobar
                    def some_method(foo, &bar)
                      #{invocation}
                    end
                  end
                  CODE
                end

                it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), $zuper, $iter)" }
              end
            end
          end

          context 'with splat' do
            context 'and block with actual params of' do
              let(:method) do
                <<-CODE
                class Foobar
                  def some_method(*stuff, &block2)
                    #{invocation}
                  end
                end
                CODE
              end

              context 'splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super(*stuff) {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
      return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), Opal.to_a(stuff), (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super(*stuff, &block2)' }

                    it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), Opal.to_a(stuff), block2.$to_proc())" }
                  end
                end
              end

              context 'no splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
      return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), $zuper, (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super(&block2)' }

                    it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), [], block2.$to_proc())" }
                  end
                end
              end

              context 'no arguments' do
                let(:invocation) { 'super()' }

                it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), [], null)" }
              end
            end

            context 'actual params of' do
              let(:method) do
                <<-CODE
                class Foobar
                  def some_method(*stuff)
                    #{invocation}
                  end
                end
                CODE
              end

              context 'splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super(*stuff) {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
      return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), Opal.to_a(stuff), (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super(*stuff, &block2)' }

                    it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), Opal.to_a(stuff), self.$block2().$to_proc())" }
                  end
                end
              end

              context 'no splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
      return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), $zuper, (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super(&block2)' }

                    it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), [], self.$block2().$to_proc())" }
                  end
                end
              end

              context 'no arguments' do
                let(:invocation) { 'super()' }

                it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false), [], null)" }
              end
            end
          end
        end

        context 'no formal parameters with actual params of' do
          let(:method) do
            <<-CODE
            class Foobar
              def regular_method
                #{invocation}
              end
            end
            CODE
          end

          context 'no splat' do
            let(:invocation) { 'super(42)' }

            it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false), [42], null)" }
          end

          context 'splat' do
            context 'with no block' do
              let(:invocation) { "args=[1,2,3]\nsuper(*args)" }

              it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false), Opal.to_a(args), null)" }
            end

            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'super(*args) {|b| foobar }' }

                it do
                  is_expected.to include <<-CODE
      return $send(self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false), Opal.to_a(self.$args()), (TMP_2 = function(b){var self = TMP_2.$$s || this;
if (b == null) b = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'super(*args, &block2)' }

                it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false), Opal.to_a(self.$args()), self.$block2().$to_proc())" }
              end
            end
          end

          context 'block' do
            context 'via variable' do
              let(:invocation) { 'super {|b| foobar }' }

              it do
                is_expected.to include <<-CODE
return $send(self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false), $zuper, (TMP_2 = function(b){var self = TMP_2.$$s || this;
if (b == null) b = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2))
                CODE
              end
            end

            context 'via reference' do
              let(:invocation) { 'super(&block)' }

              it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false), [], self.$block().$to_proc())" }
            end
          end

          context 'no arguments' do
            let(:invocation) { 'super()' }

            it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false), [], null)" }
          end
        end
      end

      context 'block' do
        let(:method) { 'stuff = lambda { super }'}

        it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null), false, true), [], $iter)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1)))" }
      end

      context 'block inside method' do
        context 'first node' do
          let(:method) do
            <<-CODE
            def in_method
              foo { super }
            end
            CODE
          end

          it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, 'in_method', (TMP_1.$$def || TMP_in_method_2), false, true), $zuper, $iter)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1))" }
        end

        context 'not first node' do
          let(:method) do
            <<-CODE
            module Foo
              def foo
                foobar
                fetch { return super }
              end
            end
            CODE
          end

          it { is_expected.to include "Opal.ret($send(self, Opal.find_iter_super_dispatcher(self, 'foo', (TMP_1.$$def || TMP_Foo_foo_2), false, true), $zuper, $iter))}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1))" }
        end

        context 'right method is called, IS THIS A NEW CASE??' do
          let(:method) do
            <<-CODE
            class Bar
              def m
                :abc
              end
            end

            class Foo < Bar
              def self.do_defining(name, &body)
                define_method(name, &body)
              end

              def self.setup
                do_defining(:m) { |*args| super(*args) }
              end
            end
            CODE
          end

          # runtime if (current_func.$$def) code should take care of locating the correct method here
          it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, 'setup', (TMP_3.$$def || TMP_Foo_setup_4), false, false), Opal.to_a(args), null)" }
        end
      end

      context 'define_method' do
        let(:method) do
          <<-CODE
          class Foobar
            #{invocation}
          end
          CODE
        end

        context 'implicit' do
          let(:invocation) { 'define_method(:wilma) { super }' }

          it do
            is_expected.to include <<-CODE
    return $send(self, 'define_method', ["wilma"], (TMP_Foobar_1 = function(){var self = TMP_Foobar_1.$$s || this;

    return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_Foobar_1.$$def || null), false, true), [], $iter)}, TMP_Foobar_1.$$s = self, TMP_Foobar_1.$$arity = 0, TMP_Foobar_1))
            CODE
          end
        end

        context 'module' do
          let(:method) do
            <<-CODE
            module Foobar
              define_method(:wilma) { super() }
            end
            CODE
          end

          it do
            is_expected.to include <<-CODE
    $send(self, 'define_method', ["wilma"], (TMP_Foobar_1 = function(){var self = TMP_Foobar_1.$$s || this;

    return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_Foobar_1.$$def || null), false, false), [], null)}, TMP_Foobar_1.$$s = self, TMP_Foobar_1.$$arity = 0, TMP_Foobar_1))
            CODE
          end
        end

        context 'anonymous class' do
          context 'not nested, only item in class' do
            let(:method) do
              <<-CODE
              Class.new do
                define_method :foo do
                  super()
                end
              end
              CODE
            end

            it do
              is_expected.to include <<-CODE
  return $send(self, 'define_method', ["foo"], (TMP_2 = function(){var self = TMP_2.$$s || this;

    return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_2.$$def || TMP_1.$$def || null), false, false), [], null)}, TMP_2.$$s = self, TMP_2.$$arity = 0, TMP_2))}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1))
              CODE
            end
          end

          context 'alongside def''d method' do
            let(:method) do
              <<-CODE
              sup = Class.new do
                def a
                  :abc
                end
              end

              Class.new(sup) do
                def fetch(&block)
                  block.call
                end

                define_method(:a) { fetch { super(&nil)} }
              end
              CODE
            end

            it do
              is_expected.to include <<-CODE.strip
    return $send(self, 'define_method', ["a"], (TMP_5 = function(){var self = TMP_5.$$s || this, TMP_6;

    return $send(self, 'fetch', [], (TMP_6 = function(){var self = TMP_6.$$s || this;

      return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_6.$$def || TMP_5.$$def || TMP_3.$$def || null), false, false), [], nil.$to_proc())}, TMP_6.$$s = self, TMP_6.$$arity = 0, TMP_6))}, TMP_5.$$s = self, TMP_5.$$arity = 0, TMP_5));}
              CODE
            end
          end

          context 'alongside another define_method' do
            let(:method) do
              <<-CODE
              sup = Class.new do
                def a
                  :abc
                end
              end

              Class.new(sup) do
                define_method(:fetch) do |&block|
                  block.call
                end

                define_method(:a) { fetch { super(&nil)} }
              end
              CODE
            end

            it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_6.$$def || TMP_5.$$def || TMP_3.$$def || null), false, false), [], nil.$to_proc())" }
          end

          context 'not last method in class' do
            let(:method) do
              <<-CODE
              sup = Class.new do
                def a
                  :abc
                end
              end

              Class.new(sup) do
                define_method(:a) { fetch { super(&nil)} }

                def fetch(&block)
                  block.call
                end
              end
              CODE
            end

            it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_5.$$def || TMP_4.$$def || TMP_3.$$def || null), false, false), [], nil.$to_proc())" }
          end
        end

        context 'inside a method' do
          let(:method) do
            <<-CODE
            module Bar
              def fetch
              end

              def foo
                some_call

                if some_arg
                  block2 = lambda { the_block }
                  define_method(:a) { fetch { super(some_arg, &block2)} }
                else
                  define_method(:a) { fetch { super(&nil)} }
                end
              end
            end
            CODE
          end

          it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, 'foo', (TMP_4.$$def || TMP_3.$$def || TMP_Bar_foo_5), false, false), [self.$some_arg()], block2.$to_proc())" }
          it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, 'foo', (TMP_7.$$def || TMP_6.$$def || TMP_Bar_foo_5), false, false), [], nil.$to_proc())" }
        end

        context 'explicit' do
          let(:invocation) { 'define_method(:wilma) { super() }' }

          it do
            is_expected.to include <<-CODE
    return $send(self, 'define_method', ["wilma"], (TMP_Foobar_1 = function(){var self = TMP_Foobar_1.$$s || this;

    return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_Foobar_1.$$def || null), false, false), [], null)}, TMP_Foobar_1.$$s = self, TMP_Foobar_1.$$arity = 0, TMP_Foobar_1))
            CODE
          end
        end

        context 'invalid case alongside other valid super cases' do
          let(:method) do
            <<-CODE
            Class.new do
              define_method(:foo) { super }

              Class.new(c1) do
                def m
                  other_method { super }
                end
              end
            end
            CODE
          end

          it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, null, (TMP_2.$$def || TMP_1.$$def || null), false, true), [], $iter)" }

          it { is_expected.to include "return $send(self, Opal.find_iter_super_dispatcher(self, 'm', (TMP_5.$$def || TMP_m_6), false, true), $zuper, $iter)" }
        end
      end

      context 'singleton' do
        let(:method) do
          <<-CODE
          class Foobar
            def self.some_method
              super
            end
          end
          CODE
        end

        it { is_expected.to include "return $send(self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false, $Foobar), $zuper, $iter)" }
      end
    end

    context 'special' do
      describe '#require_tree' do
        let(:method) { 'require_tree "./foo/bar"' }
        it 'does not change the encoding of the passed string (regression)' do
          # MRI was producing strings encoded as US-ASCII discarding the
          # original encoding and thus compiling with calls to #force_encoding.
          is_expected.not_to include('force_encoding')
        end
      end
    end
  end
end
