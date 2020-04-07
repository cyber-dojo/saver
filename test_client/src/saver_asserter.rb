# frozen_string_literal: true

require_relative 'saver_exception'

module SaverAsserter # mix-in

  def saver_assert(truth)
    unless truth
      fail SaverException.new('false')
    end
  end

  def saver_assert_batch(commands)
    saver.batch_assert(commands)
  end

end
