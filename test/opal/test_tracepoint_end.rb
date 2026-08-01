# frozen_string_literal: true
# await: *await

require "test/unit"
require "corelib/trace_point"

class TestTracePointEnd < Test::Unit::TestCase
  HEADER = <<~RUBY
    # await: true
    require "await"
  RUBY

  def eval_and_await(code)
    eval(code).__await__
  end

  def test_end_after_class_body_sync
    code = <<~RUBY
      #{HEADER}
      $trace = []
      tp = TracePoint.new(:end) { |tp| $trace << :end }
      tp.enable
      class TPESync
        $trace << :in_body_before
        $trace << :in_body_after
      end
      $trace << :after_class
      tp.disable
      $trace
    RUBY

    trace = eval_and_await(code)

    assert_equal [:in_body_before, :in_body_after, :end, :after_class], trace
  end

  def test_end_after_class_body_async
    code = <<~RUBY
      #{HEADER}
      $trace = []
      tp = TracePoint.new(:end) { |tp| $trace << :end }
      tp.enable
      class TPEAsync
        $trace << :in_body_before
        sleep(0.001).__await__
        $trace << :in_body_after
      end
      $trace << :after_class
      tp.disable
      $trace
    RUBY

    trace = eval_and_await(code)

    assert_equal [:in_body_before, :in_body_after, :end, :after_class], trace
  end

  def test_end_after_module_body_sync
    code = <<~RUBY
      #{HEADER}
      $trace = []
      tp = TracePoint.new(:end) { |tp| $trace << :end }
      tp.enable
      module TPESyncMod
        $trace << :in_body_before
        $trace << :in_body_after
      end
      $trace << :after_module
      tp.disable
      $trace
    RUBY

    trace = eval_and_await(code)
    assert_equal [:in_body_before, :in_body_after, :end, :after_module], trace
  end

  def test_end_after_module_body_async
    code = <<~RUBY
      #{HEADER}
      $trace = []
      tp = TracePoint.new(:end) { |tp| $trace << :end }
      tp.enable
      module TPEAsyncMod
        $trace << :in_body_before
        sleep(0.001).__await__
        $trace << :in_body_after
      end
      $trace << :after_module
      tp.disable
      $trace
    RUBY

    trace = eval_and_await(code)
    assert_equal [:in_body_before, :in_body_after, :end, :after_module], trace
  end
end

