# frozen_string_literal: true

module HttpJson

  class RequestError < RuntimeError

    def initialize(message)
      super
    end

  end

end
