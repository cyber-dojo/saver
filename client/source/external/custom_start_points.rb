require_relative '../http_json_hash/service'
require_relative 'http'

module External

  class CustomStartPoints

    def initialize
      service = 'custom-start-points'
      port = ENV['CYBER_DOJO_CUSTOM_START_POINTS_PORT'].to_i
      http = External::Http.new
      @http = HttpJsonHash::service(self.class.name, http, service, port)
    end

    def ready?
      @http.get(__method__, {})
    end

    def display_names
      @http.get(:names, {})
    end

    def manifest(display_name)
      @http.get(__method__, { name:display_name })
    end

  end

end
