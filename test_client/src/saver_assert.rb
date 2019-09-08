# frozen_string_literal: true

require_relative 'saver_exception'

module SaverAssert # mix-in

  def saver_assert(result, expected)
    unless result === expected
      message = "expected:#{expected},"
      message += "actual:#{result}"
      fail SaverException.new(message)
    end
  end

end
