# frozen_string_literal: true
require_relative 'test_base'

class KatasEventsTest < TestBase

  def self.id58_prefix
    'j8S'
  end

  test '2R6', %w( v0 example ) do
    actual = katas_events([V0_KATA_ID,V0_KATA_ID], [2,3])
    expected = {
      V0_KATA_ID => {
        "2" => kata_event_k5ZTk0_2,
        "3" => kata_event_k5ZTk0_3,
      }
    }
    assert_equal expected, actual
  end

  test '1P3', %w( v1 example ) do
    actual = katas_events([V1_KATA_ID,V1_KATA_ID], [1,2])
    expected = {
      V1_KATA_ID => {
        "1" => kata_event_rUqcey_1,
        "2" => kata_event_rUqcey_2,
      }
    }
    assert_equal expected, actual
  end

end
