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
        it { is_expected.to include "return (!(Opal.find_super_dispatcher(self, 'some_method', TMP_1).$$stub) ? \"super\" : nil);" }
      end

      context 'method missing off' do
        let(:compiler) { Opal::Compiler.new(method, method_missing: false) }

        it { is_expected.to include "return ((Opal.find_super_dispatcher(self, 'some_method', TMP_1)) != null ? \"super\" : nil);" }
      end
    end

    context 'inside block' do
      context 'implicit' do
        let(:method) { 'lambda { defined? super }' }

        it { is_expected.to include "return (!(Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null)).$$stub) ? \"super\" : nil)}, TMP_1.$$s = self, TMP_1), $a).call($b)" }
      end

      context 'explicit' do
        let(:method) { 'lambda { defined? super() }' }

        it { is_expected.to include "return (!(Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null)).$$stub) ? \"super\" : nil)}, TMP_1.$$s = self, TMP_1), $a).call($b)" }
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
    return ($a = ($b = self).$call_method, $a.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).apply($b, Opal.to_a(stuff));
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method *stuff, &block2' }

                it { is_expected.to include "return ($a = ($b = self).$call_method, $a.$$p = block2.$to_proc(), $a).apply($b, Opal.to_a(stuff));" }
              end
            end
          end

          context 'no splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return ($a = ($b = self).$call_method, $a.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).call($b);
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method &block2' }

                it { is_expected.to include "return ($a = ($b = self).$call_method, $a.$$p = block2.$to_proc(), $a).call($b);" }
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
    return ($a = ($b = self).$call_method, $a.$$p = (TMP_1 = function(a){var self = TMP_1.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1), $a).apply($b, Opal.to_a(stuff));
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method *stuff, &block2' }

                it { is_expected.to include "return ($a = ($b = self).$call_method, $a.$$p = self.$block2().$to_proc(), $a).apply($b, Opal.to_a(stuff));" }
              end
            end
          end

          context 'no splat' do
            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'call_method {|a| foobar }' }

                it do
                  is_expected.to include <<-CODE
    return ($a = ($b = self).$call_method, $a.$$p = (TMP_1 = function(a){var self = TMP_1.$$s || this;
if (a == null) a = nil;
    return self.$foobar()}, TMP_1.$$s = self, TMP_1), $a).call($b);
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'call_method &block2' }

                it { is_expected.to include "return ($a = ($b = self).$call_method, $a.$$p = self.$block2().$to_proc(), $a).call($b);" }
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

          it { is_expected.to include 'return self.$another_method(42);' }
        end

        context 'splat' do
          context 'with no block' do
            let(:invocation) { 'another_method(*args)' }

            it { is_expected.to include 'return ($a = self).$another_method.apply($a, Opal.to_a(self.$args()));' }
          end

          context 'with block' do
            context 'via variable' do
              let(:invocation) { 'another_method(*args) {|b| foobar }' }

              it { is_expected.to include "return ($a = ($b = self).$another_method, $a.$$p = (TMP_1 = function(b){var self = TMP_1.$$s || this;\nif (b == null) b = nil;\n    return self.$foobar()}, TMP_1.$$s = self, TMP_1), $a).apply($b, Opal.to_a(self.$args()));" }
            end

            context 'via reference' do
              let(:invocation) { 'another_method(*args, &block2)' }

              it { is_expected.to include "return ($a = ($b = self).$another_method, $a.$$p = self.$block2().$to_proc(), $a).apply($b, Opal.to_a(self.$args()));" }
            end
          end
        end

        context 'block' do
          context 'via variable' do
            let(:invocation) { 'another_method {|b| foobar }' }

            it { is_expected.to include "return ($a = ($b = self).$another_method, $a.$$p = (TMP_1 = function(b){var self = TMP_1.$$s || this;\nif (b == null) b = nil;\n    return self.$foobar()}, TMP_1.$$s = self, TMP_1), $a).call($b);" }
          end

          context 'via reference' do
            let(:invocation) { 'another_method(&block)' }

            it { is_expected.to include 'return ($a = ($b = self).$another_method, $a.$$p = self.$block().$to_proc(), $a).call($b);' }
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

              it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = null, $a).call($b);" }
            end

            context 'implicit arguments' do
              let(:invocation) { 'super' }

              context 'no block' do
                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = $iter, $a).apply($b, $zuper);" }
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

                it { is_expected.to include "$zuper_length = bar != nil ? arguments.length - 1 : arguments.length;" }
                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = $iter, $a).apply($b, $zuper);" }
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
    return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).apply($b, Opal.to_a(stuff));
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super *stuff, &block2' }

                    it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = block2.$to_proc(), $a).apply($b, Opal.to_a(stuff));" }
                  end
                end
              end

              context 'no splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
    return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).apply($b, $zuper);
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super &block2' }

                    it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = block2.$to_proc(), $a).call($b);" }
                  end
                end
              end

              context 'no arguments' do
                let(:invocation) { 'super()' }

                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = null, $a).call($b);" }
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
      return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).apply($b, Opal.to_a(stuff));
                      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super *stuff, &block2' }

                    it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = self.$block2().$to_proc(), $a).apply($b, Opal.to_a(stuff));" }
                  end
                end
              end

              context 'no splat' do
                context 'with block' do
                  context 'via variable' do
                    let(:invocation) { 'super {|a| foobar }' }

                    it do
                      is_expected.to include <<-CODE
      return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = (TMP_2 = function(a){var self = TMP_2.$$s || this;
if (a == null) a = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).apply($b, $zuper);
      CODE
                    end
                  end

                  context 'via reference' do
                    let(:invocation) { 'super &block2' }

                    it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = self.$block2().$to_proc(), $a).call($b);" }
                  end
                end
              end

              context 'no arguments' do
                let(:invocation) { 'super()' }

                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1)), $a.$$p = null, $a).call($b);" }
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

            it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_1)), $a.$$p = null, $a).call($b, 42);" }
          end

          context 'splat' do
            context 'with no block' do
              let(:invocation) { "args=[1,2,3]\nsuper(*args)" }

              it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_1)), $a.$$p = null, $a).apply($b, Opal.to_a(args));" }
            end

            context 'with block' do
              context 'via variable' do
                let(:invocation) { 'super(*args) {|b| foobar }' }

                it do
                  is_expected.to include <<-CODE
      return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_1)), $a.$$p = (TMP_2 = function(b){var self = TMP_2.$$s || this;
if (b == null) b = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).apply($b, Opal.to_a(self.$args()));
                  CODE
                end
              end

              context 'via reference' do
                let(:invocation) { 'super(*args, &block2)' }

                it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_1)), $a.$$p = self.$block2().$to_proc(), $a).apply($b, Opal.to_a(self.$args()));" }
              end
            end
          end

          context 'block' do
            context 'via variable' do
              let(:invocation) { 'super {|b| foobar }' }

              it do
                is_expected.to include <<-CODE
      return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_1)), $a.$$p = (TMP_2 = function(b){var self = TMP_2.$$s || this;
if (b == null) b = nil;
      return self.$foobar()}, TMP_2.$$s = self, TMP_2), $a).apply($b, $zuper);
                CODE
              end
            end

            context 'via reference' do
              let(:invocation) { 'super(&block)' }

              it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_1)), $a.$$p = self.$block().$to_proc(), $a).call($b);" }
            end
          end

          context 'no arguments' do
            let(:invocation) { 'super()' }

            it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'regular_method', TMP_1)), $a.$$p = null, $a).call($b);" }
          end
        end
      end

      context 'block' do
        let(:method) { 'stuff = lambda { super }'}

        it { is_expected.to include "return ($c = ($d = self, self.$raise('super called outside of method')), $c.$$p = $iter, $c).apply($d)}, TMP_1.$$s = self, TMP_1), $a).call($b)" }
      end

      context 'block inside method' do
        let(:method) do
          <<-CODE
          def in_method
            foo { super }
          end
          CODE
        end

        it { is_expected.to include "return ($c = ($d = self, Opal.find_super_dispatcher(self, 'in_method', TMP_2)), $c.$$p = $iter, $c).apply($d, $zuper)}, TMP_1.$$s = self, TMP_1), $a).call($b);" }
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

          it { is_expected.to include "return ($c = ($d = self, self.$raise('implicit argument passing of super from method defined by define_method() is not supported. Specify all arguments explicitly')), $c.$$p = $iter, $c).apply($d)}, TMP_1.$$s = self, TMP_1), $a).call($b, \"wilma\")" }
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
    ($a = ($b = self).$define_method, $a.$$p = (TMP_1 = function(){var self = TMP_1.$$s || this, $c, $d;

    return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null))), $c.$$p = null, $c).call($d)}, TMP_1.$$s = self, TMP_1), $a).call($b, "wilma")
            CODE
          end
        end

        context 'anonymous class' do
          let(:method) do
            <<-CODE
            Class.new do
              define_method :foo do
                super()
              end
            end
            CODE
          end

          it { is_expected.to include "return ($e = ($f = self, Opal.find_iter_super_dispatcher(self, null, (TMP_2.$$def || TMP_1.$$def || null))), $e.$$p = null, $e).call($f)}, TMP_2.$$s = self, TMP_2), $c).call($d, \"foo\")}, TMP_1.$$s = self, TMP_1), $a).call($b)" }
        end

        context 'explicit' do
          let(:invocation) { 'define_method(:wilma) { super() }' }

          it do
            is_expected.to include <<-CODE
    return ($a = ($b = self).$define_method, $a.$$p = (TMP_1 = function(){var self = TMP_1.$$s || this, $c, $d;

    return ($c = ($d = self, Opal.find_iter_super_dispatcher(self, null, (TMP_1.$$def || null))), $c.$$p = null, $c).call($d)}, TMP_1.$$s = self, TMP_1), $a).call($b, "wilma")
            CODE
          end
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

        it { is_expected.to include "return ($a = ($b = self, Opal.find_super_dispatcher(self, 'some_method', TMP_1, $Foobar)), $a.$$p = $iter, $a).apply($b, $zuper);" }
      end
    end
  end
end
