# frozen_string_literal: true

module External

  class Time

    def initialize(_)
    end

    def now
      t = Time.now
      [t.year, t.month, t.day, t.hour, t.min, t.sec, t.usec]
    end

  end

end
