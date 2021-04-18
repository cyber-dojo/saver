# frozen_string_literal: true

module External

  class Random

    def initialize(_)
    end

    def sample(size)
      # Careful to avoid recursion
      ::Random.rand(size)
    end

  end

end