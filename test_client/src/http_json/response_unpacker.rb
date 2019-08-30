require 'json'

module HttpJson

  class ResponseUnpacker

    def initialize(requester, exception_class)
      @requester = requester
      @exception_class = exception_class
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s)
    rescue => error
      fail @exception_class, error.message
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def post(path, args)
      response = @requester.post(path, args)
      unpacked(response.body, path.to_s)
    rescue => error
      fail @exception_class, error.message
    end

    private

    def unpacked(body, path)
      json = json_parse(body)
      if json.has_key?('exception')
        fail JSON.pretty_generate(json['exception'])
      end
      json[path]
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def json_parse(body)
      JSON.parse(body)
    end

  end

end
