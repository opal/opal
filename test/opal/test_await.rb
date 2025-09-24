# frozen_string_literal: true
# await: true

require "test/unit"

class TestAwait < Test::Unit::TestCase
  stdheader = <<~RUBY
    # await: true
    require "await"
  RUBY

  autoawaitheader = <<~RUBY
    # await: *await*
    require "await"
  RUBY

  tests = {
    test_await_in_top: [<<~RUBY, 6],
      #{stdheader}
      $taval = 5
      sleep(0.001).__await__
      $taval = 6
    RUBY
    test_await_in_method: [<<~RUBY, 7],
      #{stdheader}
      $taval = 5
      def xx_taim
        sleep(0.001).__await__
        $taval = 7
      end
      xx_taim.__await__
    RUBY
    test_await_in_block: [<<~RUBY, 0],
      #{stdheader}
      $taval = 5
      xx_taib = proc do
        sleep(0.001).__await__
        $taval = 0
      end
      xx_taib.().__await__
    RUBY
    test_await_in_instance_method: [<<~RUBY, 3],
      #{stdheader}
      $taval = 5
      class XXTaiim
        def xx_taiim
          sleep(0.001).__await__
          $taval = 3
        end
      end
      XXTaiim.new.xx_taiim.__await__
    RUBY
    test_await_in_class_method: [<<~RUBY, 4],
      #{stdheader}
      $taval = 5
      class XXTaicm
        def self.xx_taicm
          sleep(0.001).__await__
          $taval = 4
        end
      end
      XXTaicm.xx_taicm.__await__
    RUBY
    test_await_on_promise: [<<~RUBY, 8],
      #{stdheader}
      $taval = PromiseV2.value(8).__await__
    RUBY
    test_await_in_while: [<<~RUBY, 9],
      #{stdheader}
      $taval = 5
      begin
        sleep(0.001).__await__
        $taval = 9
      end while false
    RUBY
    test_await_in_while_expr: [<<~RUBY, -9],
      #{stdheader}
      $taval = 5
      x = if true
        begin
          sleep(0.001).__await__
          $taval = -9
        end while false
      end
    RUBY
    test_await_in_case: [<<~RUBY, 88],
      #{stdheader}
      $taval = 5
      case true
      when true
        sleep(0.001).__await__
        $taval = 88
      end
    RUBY
    test_await_in_case_expr: [<<~RUBY, 99],
      #{stdheader}
      $taval = 5
      x = case true
      when true
        sleep(0.001).__await__
        $taval = 99
      end
    RUBY
    test_await_in_rescue: [<<~RUBY, 10],
      #{stdheader}
      $taval = 5
      begin
        sleep(0.001).__await__
        nomethoderror
      rescue
        sleep(0.001).__await__
        $taval = 10
      end
    RUBY
    test_await_in_ensure: [<<~RUBY, 11],
      #{stdheader}
      $taval = 5
      begin
        sleep(0.001).__await__
        nomethoderror
      rescue
        sleep(0.001).__await__
      ensure
        sleep(0.001).__await__
        $taval = 11
      end
    RUBY
    test_await_in_ensure_expr: [<<~RUBY, -11],
      #{stdheader}
      $taval = 5
      x = begin
        sleep(0.001).__await__
        nomethoderror
      rescue
        sleep(0.001).__await__
      ensure
        sleep(0.001).__await__
        $taval = -11
      end
    RUBY
    test_await_in_module: [<<~RUBY, 12],
      #{stdheader}
      $taval = 5
      module XYTaim
        sleep(0.001).__await__
        $taval = 12
      end
    RUBY
    test_await_in_class: [<<~RUBY, 13],
      #{stdheader}
      $taval = 5
      class XYTaic
        sleep(0.001).__await__
        $taval = 13
      end
    RUBY
    test_await_in_and: [<<~RUBY, 14],
      #{stdheader}
      ($taval = 5) && (PromiseV2.value(4).__await__) && ($taval = 14)
    RUBY
    test_await_in_plus: [<<~RUBY, 15],
      #{stdheader}
      $taval = 5
      $taval = PromiseV2.value(5).__await__ + 10
    RUBY
    # Bug before Opal 1.6: compiled autoawait expressions had wrong parentheses rules
    test_autoawait_awaiting: [<<~RUBY, "very correct"],
      #{autoawaitheader}
      $taval = "incorrect"
      $taval = PromiseV2.value("also incorrect").await.sub("also in", "")
      $taval = PromiseV2.value("very ").await + $taval
    RUBY
    test_autoawait_instance_exec_await: [<<~RUBY, 2*3*5*7*11*13],
      # backtick_javascript: true
      #{autoawaitheader}
      $taval = 1
      module AutoawaitTemporary1
        $block_with_module_self = proc do
          # Ensure that block.$$s is generated:
          self
          # AutoawaitTemporary2.$$eval should be true, block.$$s should be unset
          `\#{AutoawaitTemporary2}.$$eval` && ($taval *= PromiseV2.value(2).await)
          `block.$$s === null` && ($taval *= PromiseV2.value(3).await)
        end
        block = $block_with_module_self
      end
      block = $block_with_module_self
      module AutoawaitTemporary2; end
      # AutoawaitTemporary2.$$eval should be false, block.$$s should refer to AutoawaitTemporary1
      `\#{AutoawaitTemporary2}.$$eval` || ($taval *= PromiseV2.value(5).await)
      `block.$$s === \#{AutoawaitTemporary1}` && ($taval *= PromiseV2.value(7).await)
      module AutoawaitTemporary2
        instance_exec_await(&$block_with_module_self)
      end
      # both should get their values back after instance_exec_await is finished
      `\#{AutoawaitTemporary2}.$$eval` || ($taval *= PromiseV2.value(11).await)
      `block.$$s === \#{AutoawaitTemporary1}` && ($taval *= PromiseV2.value(13).await)
    RUBY
  }

  tests.each do |name,(code,expect)|
    define_method name do
      eval(code).__await__
      assert_equal(expect, $taval)
    end
  end
end
