require 'lib/spec_helper'

describe Opal::Compiler do
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
        it { is_expected.to include "return (!(Opal.find_super_dispatcher(self, 'some_method', TMP_some_method_1, true).$$stub) ? \"super\" : nil)" }
      end

      context 'method missing off' do
        let(:compiler) { Opal::Compiler.new(method, method_missing: false) }

        it { is_expected.to include "return ((Opal.find_super_dispatcher(self, 'some_method', TMP_some_method_1, true)) != null ? \"super\" : nil)" }
      end
    end

    context 'inside block' do
      context 'implicit' do
        let(:method) { 'lambda { defined? super }' }

        it { is_expected.to include "return (!(Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null), true, false).$$stub) ? \"super\" : nil)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1), $a).call($b)" }
      end

      context 'explicit' do
        let(:method) { 'lambda { defined? super() }' }

        it { is_expected.to include "return (!(Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null), true, false).$$stub) ? \"super\" : nil)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1), $a).call($b)" }
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
    return ($b = ($c = self).$call_method, $b.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $b).apply($c, Opal.to_a(stuff))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method *stuff, &block2' }

                it { is_expected.to include "return ($b = ($c = self).$call_method, $b.$$p = block2.$to_proc(), $b).apply($c, Opal.to_a(stuff))" }
              end
            end
          end

          context 'no splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return ($b = ($c = self).$call_method, $b.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $b).call($c)
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method &block2' }

                it { is_expected.to include "return ($b = ($c = self).$call_method, $b.$$p = block2.$to_proc(), $b).call($c)" }
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
    return ($b = ($c = self).$call_method, $b.$$p = (TMP_1 = function(a){var self = TMP_1.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1), $b).apply($c, Opal.to_a(stuff))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method *stuff, &block2' }

                it { is_expected.to include "return ($b = ($c = self).$call_method, $b.$$p = self.$block2().$to_proc(), $b).apply($c, Opal.to_a(stuff))" }
              end
            end
          end

          context 'no splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return ($b = ($c = self).$call_method, $b.$$p = (TMP_1 = function(a){var self = TMP_1.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1), $b).call($c)
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method &block2' }

                it { is_expected.to include "return ($b = ($c = self).$call_method, $b.$$p = self.$block2().$to_proc(), $b).call($c)" }
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

            it { is_expected.to include 'return ($a = self).$another_method.apply($a, Opal.to_a(self.$args()))' }
          end

          context 'with block' do
            context 'via variable' do
              let(:invocation) { 'another_method(*args) {|b| foobar }' }

              it { is_expected.to include "return ($a = ($b = self).$another_method, $a.$$p = (TMP_1 = function(b){var self = TMP_1.$$s || this;\nif (b == null) b = nil;\n    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1), $a).apply($b, Opal.to_a(self.$args()))" }
            end

            context 'via reference' do
              let(:invocation) { 'another_method(*args, &block2)' }

              it { is_expected.to include "return ($a = ($b = self).$another_method, $a.$$p = self.$block2().$to_proc(), $a).apply($b, Opal.to_a(self.$args()))" }
            end
          end
        end

        context 'block' do
          context 'via variable' do
            let(:invocation) { 'another_method {|b| foobar }' }

            it { is_expected.to include "return ($a = ($b = self).$another_method, $a.$$p = (TMP_1 = function(b){var self = TMP_1.$$s || this;\nif (b == null) b = nil;\n    return self.$foobar()}, TMP_1.$$s = self, TMP_1.$$arity = 1, TMP_1), $a).call($b)" }
          end

          context 'via reference' do
            let(:invocation) { 'another_method(&block)' }

            it { is_expected.to include 'return ($a = ($b = self).$another_method, $a.$$p = self.$block().$to_proc(), $a).call($b)' }
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

              it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $a.$$p = null, $a).call($b)" }
            end

            context 'implicit arguments' do
              let(:invocation) { 'super' }

              context 'no block' do
                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $a.$$p = $iter, $a).apply($b, $zuper)" }
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

                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $a.$$p = $iter, $a).apply($b, $zuper)" }
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
    return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $b).apply($c, Opal.to_a(stuff))
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super *stuff, &block2' }

                    it { is_expected.to include "return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = block2.$to_proc(), $b).apply($c, Opal.to_a(stuff))" }
                  end
                end
              end

              context 'no splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
    return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $b).apply($c, $zuper)
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super &block2' }

                    it { is_expected.to include "return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = block2.$to_proc(), $b).call($c)" }
                  end
                end
              end

              context 'no arguments' do
                let(:invocation) { 'super()' }

                it { is_expected.to include "return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = null, $b).call($c)" }
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
      return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $b).apply($c, Opal.to_a(stuff))
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super *stuff, &block2' }

                    it { is_expected.to include "return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = self.$block2().$to_proc(), $b).apply($c, Opal.to_a(stuff))" }
                  end
                end
              end

              context 'no splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
      return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $b).apply($c, $zuper)
      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super &block2' }

                    it { is_expected.to include "return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = self.$block2().$to_proc(), $b).call($c)" }
                  end
                end
              end

              context 'no arguments' do
                let(:invocation) { 'super()' }

                it { is_expected.to include "return ($b = ($c = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false)), $b.$$p = null, $b).call($c)" }
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

            it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false)), $a.$$p = null, $a).call($b, 42)" }
          end

          context 'splat' do
            context 'with no block' do
              let(:invocation) { "args=[1,2,3]\nsuper(*args)" }

              it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false)), $a.$$p = null, $a).apply($b, Opal.to_a(args))" }
            end

            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'super(*args) {|b| foobar }' }

                it do
                  is_expected.to include <<-CODE
      return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false)), $a.$$p = (TMP_2 = function(b){var self = TMP_2.$$s || this;
if (b == null) b = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $a).apply($b, Opal.to_a(self.$args()))
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'super(*args, &block2)' }

                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false)), $a.$$p = self.$block2().$to_proc(), $a).apply($b, Opal.to_a(self.$args()))" }
              end
            end
          end

          context 'block' do
            context 'via variable' do
              let(:invocation) { 'super {|b| foobar }' }

              it do
                is_expected.to include <<-CODE
      return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false)), $a.$$p = (TMP_2 = function(b){var self = TMP_2.$$s || this;
if (b == null) b = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2.$$arity = 1, TMP_2), $a).apply($b, $zuper)
                CODE
              end
            end

            context 'via reference' do
              let(:invocation) { 'super(&block)' }

              it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false)), $a.$$p = self.$block().$to_proc(), $a).call($b)" }
            end
          end

          context 'no arguments' do
            let(:invocation) { 'super()' }

            it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_Foobar_regular_method_1, false)), $a.$$p = null, $a).call($b)" }
          end
        end
      end

      context 'block' do
        let(:method) { 'stuff = lambda { super }'}

        it { is_expected.to include "return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null), false, true)), $c.$$p = $iter, $c).apply($d)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1), $a).call($b)" }
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

          it { is_expected.to include "return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, 'in_method', (TMP_1.$$def || TMP_in_method_2), false, true)), $c.$$p = $iter, $c).apply($d, $zuper)}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1), $a).call($b)" }
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

          it { is_expected.to include "Opal.ret(($c = ($d = self, Opal.find_iter_super_dispatcher(self, 'foo', (TMP_1.$$def || TMP_Foo_foo_2), false, true)), $c.$$p = $iter, $c).apply($d, $zuper))}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1), $a).call($b)" }
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
          it { is_expected.to include "return ($d = ($e = self, Opal.find_iter_super_dispatcher(self, 'setup', (TMP_3.$$def || TMP_Foo_setup_4), false, false)), $d.$$p = null, $d).apply($e, Opal.to_a(args))}, TMP_3.$$s = self, TMP_3.$$arity = -1, TMP_3), $a).call($b, \"m\")" }
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

          it { is_expected.to include "return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, null, (TMP_Foobar_1.$$def || null), false, true)), $c.$$p = $iter, $c).apply($d)}, TMP_Foobar_1.$$s = self, TMP_Foobar_1.$$arity = 0, TMP_Foobar_1), $a).call($b, \"wilma\")" }
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
    ($a = ($b = self).$define_method, $a.$$p = (TMP_Foobar_1 = function(){var self = TMP_Foobar_1.$$s || this, $c, $d;

    return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, null, (TMP_Foobar_1.$$def || null), false, false)), $c.$$p = null, $c).call($d)}, TMP_Foobar_1.$$s = self, TMP_Foobar_1.$$arity = 0, TMP_Foobar_1), $a).call($b, "wilma")
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

            it { is_expected.to include "return ($e = ($f = self, Opal.find_iter_super_dispatcher(self, null, (TMP_2.$$def || TMP_1.$$def || null), false, false)), $e.$$p = null, $e).call($f)}, TMP_2.$$s = self, TMP_2.$$arity = 0, TMP_2), $c).call($d, \"foo\")}, TMP_1.$$s = self, TMP_1.$$arity = 0, TMP_1), $a).call($b)" }
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

            it { is_expected.to include "return ($h = ($i = self, Opal.find_iter_super_dispatcher(self, null, (TMP_6.$$def || TMP_5.$$def || TMP_3.$$def || null), false, false)), $h.$$p = nil.$to_proc(), $h).call($i)}, TMP_6.$$s = self, TMP_6.$$arity = 0, TMP_6), $f).call($g)}, TMP_5.$$s = self, TMP_5.$$arity = 0, TMP_5), $d).call($e, \"a\");}, TMP_3.$$s = self, TMP_3.$$arity = 0, TMP_3), $a).call($c, sup);" }
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

            it { is_expected.to include "return ($i = ($j = self, Opal.find_iter_super_dispatcher(self, null, (TMP_6.$$def || TMP_5.$$def || TMP_3.$$def || null), false, false)), $i.$$p = nil.$to_proc(), $i).call($j)}, TMP_6.$$s = self, TMP_6.$$arity = 0, TMP_6), $g).call($h)}, TMP_5.$$s = self, TMP_5.$$arity = 0, TMP_5), $d).call($f, \"a\");}, TMP_3.$$s = self, TMP_3.$$arity = 0, TMP_3), $a).call($c, sup)" }
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

            it { is_expected.to include "return ($h = ($i = self, Opal.find_iter_super_dispatcher(self, null, (TMP_5.$$def || TMP_4.$$def || TMP_3.$$def || null), false, false)), $h.$$p = nil.$to_proc(), $h).call($i)}, TMP_5.$$s = self, TMP_5.$$arity = 0, TMP_5), $f).call($g)}, TMP_4.$$s = self, TMP_4.$$arity = 0, TMP_4), $d).call($e, \"a\")" }
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

          it { is_expected.to include "return ($f = ($g = self, Opal.find_iter_super_dispatcher(self, 'foo', (TMP_4.$$def || TMP_3.$$def || TMP_Bar_foo_5), false, false)), $f.$$p = block2.$to_proc(), $f).call($g, self.$some_arg())}, TMP_4.$$s = self, TMP_4.$$arity = 0, TMP_4), $d).call($e)}, TMP_3.$$s = self, TMP_3.$$arity = 0, TMP_3), $a).call($c, \"a\")" }
          it { is_expected.to include "return ($g = ($h = self, Opal.find_iter_super_dispatcher(self, 'foo', (TMP_7.$$def || TMP_6.$$def || TMP_Bar_foo_5), false, false)), $g.$$p = nil.$to_proc(), $g).call($h)}, TMP_7.$$s = self, TMP_7.$$arity = 0, TMP_7), $e).call($f)}, TMP_6.$$s = self, TMP_6.$$arity = 0, TMP_6), $a).call($d, \"a\")" }
        end

        context 'explicit' do
          let(:invocation) { 'define_method(:wilma) { super() }' }

          it do
            is_expected.to include <<-CODE
    return ($a = ($b = self).$define_method, $a.$$p = (TMP_Foobar_1 = function(){var self = TMP_Foobar_1.$$s || this, $c, $d;

    return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, null, (TMP_Foobar_1.$$def || null), false, false)), $c.$$p = null, $c).call($d)}, TMP_Foobar_1.$$s = self, TMP_Foobar_1.$$arity = 0, TMP_Foobar_1), $a).call($b, "wilma")
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

          it { is_expected.to include "return ($e = ($f = self, Opal.find_iter_super_dispatcher(self, null, (TMP_2.$$def || TMP_1.$$def || null), false, true)), $e.$$p = $iter, $e).apply($f)}, TMP_2.$$s = self, TMP_2.$$arity = 0, TMP_2), $c).call($d, \"foo\")" }

          it { is_expected.to include "return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, 'm', (TMP_5.$$def || TMP_m_6), false, true)), $c.$$p = $iter, $c).apply($d, $zuper)}, TMP_5.$$s = self, TMP_5.$$arity = 0, TMP_5), $a).call($b)" }
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

        it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_Foobar_some_method_1, false, $Foobar)), $a.$$p = $iter, $a).apply($b, $zuper)" }
      end
    end
  end
end
