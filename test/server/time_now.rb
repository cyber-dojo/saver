# frozen_string_literal: true

require_relative 'test_base'

class TimeNowStubTest < TestBase

  test 'b5D192', %w(
  | stubbed values are returned
  ) do
    ymdhms = [2021, 4, 18, 19, 12, 23, 454_231]
    t = TimeStub.new(ymdhms)
    assert_equal ymdhms, t.now
  end

  test 'b5D193', %w(
  | stubbing more than one time
  ) do
    ymdhms = [2021, 4, 18, 19, 12, 23, 454_231]
    t = TimeStub.new(ymdhms, ymdhms)
    assert_equal ymdhms, t.now
    assert_equal ymdhms, t.now
    assert_nil t.now
  end
end
