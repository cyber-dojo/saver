require_relative 'test_base'

class TimeNowTest < TestBase

  def self.id58_prefix
    'a7D'
  end

  test '190', %w( time.now sanity check ) do
    now = time.now
    assert_equal Array, now.class
    assert_equal 7, now.size
    now.each { |i| assert_equal Integer, i.class }
  end

end

class TimeNowStubTest < TestBase

  def self.id58_prefix
    'b5D'
  end

  test '192', %w( stubbed values are returned ) do
    ymdhms = [2021,4,18, 19,12,23,454231]
    t = TimeStub.new(ymdhms)
    assert_equal ymdhms, t.now
  end

end
