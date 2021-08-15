require_relative '../http_json_hash/service'
require_relative 'http'

module External

  class ExercisesStartPoints

    def initialize
      service = 'exercises-start-points'
      port = ENV['CYBER_DOJO_EXERCISES_START_POINTS_PORT'].to_i
      http = External::Http.new
      @http = HttpJsonHash::service(self.class.name, http, service, port)
    end

    def display_names
      @http.get(:names, {})
    end

  end

end
