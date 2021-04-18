# frozen_string_literal: true

module External

  class Prober

    def initialize(_)
    end

    def sha
      ENV['SHA']
    end

    def alive?
      true
    end

    def ready?
      true
    end

  end

end
