# frozen_string_literal: true

module SaverAssert # mix-in

  def saver_assert(truth)
    saver_assert_equal(true, truth)
  end

  def saver_assert_equal(result, expected)
    unless result === expected
      message = "expected:#{expected},"
      message += "actual:#{result}"
      fail ArgumentError.new(message)
    end
  end

end
