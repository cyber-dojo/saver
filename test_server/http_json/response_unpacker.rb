# frozen_string_literal: true

require 'json'

module HttpJson

  class ResponseUnpacker

    def initialize(requester)
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s)
    end

    private

    def unpacked(body, path)
      json = JSON.parse(body)
      json[path]
    end

  end

end
