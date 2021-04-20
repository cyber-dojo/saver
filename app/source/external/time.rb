# frozen_string_literal: true

module External

  class Time

    def now
      t = ::Time.now # Careful to avoid recursion
      [t.year, t.month, t.day, t.hour, t.min, t.sec, t.usec]
    end

  end

end
