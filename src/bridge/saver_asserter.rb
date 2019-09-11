# frozen_string_literal: true

module SaverAsserter # mix-in

  def saver_assert(truth)
    unless truth
      fail ArgumentError.new('false')
    end
  end

  def saver_assert_batch(commands)
    result = saver.batch(commands)
    if result.any?(false)
      fail ArgumentError.new(result.inspect)
    end
    result
  end

end
