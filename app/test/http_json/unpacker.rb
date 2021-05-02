# frozen_string_literal: true
require_relative 'service_error'
require 'json'

module HttpJson

  class Unpacker

    def initialize(name, requester)
      @name = name
      @requester = requester
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s, args)
    end

    private

    def unpacked(body, path, args)
      json = JSON.parse!(body)
      unless json.instance_of?(Hash)
        service_error(path, args, body, 'body is not JSON Hash')
      end
      if json.has_key?('exception')
        service_error(path, args, body, 'body has embedded exception')
      end
      unless json.has_key?(path)
        service_error(path, args, body, 'body is missing :path key')
      end
      json[path]
    rescue JSON::ParserError
      service_error(path, args, body, 'body is not JSON')
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def service_error(path, args, body, message)
      fail ::HttpJson::ServiceError.new(path, args, @name, body, message)
    end

  end

end
