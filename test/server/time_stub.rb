# frozen_string_literal: true

class TimeStub

  def initialize(*stubs)
    @stubs = stubs
    @n = 0
  end

  def now
    stub = @stubs[@n]
    @n += 1
    stub
  end

end

class TimeStubTest < TestBase

  def self.hex_prefix
    'b5D'
  end

  test '192', %w( stubbed values are returned ) do
    ymdhms = [2021,4,18, 19,12,23,454231]
    t = TimeStub.new(ymdhms)
    assert_equal ymdhms, t.now
  end

end
