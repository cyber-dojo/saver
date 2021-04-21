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
