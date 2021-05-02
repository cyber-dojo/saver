# frozen_string_literal: true
require 'json'

module HttpJson

  class Unpacker

    def initialize(requester)
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      json = JSON.parse!(response.body)
      json[path.to_s]
    end

  end

end
