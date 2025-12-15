require 'net/http'

module External
  class Http

    def get(uri)
      KLASS::Get.new(uri)
    end

    def start(hostname, port, req)
      KLASS.start(hostname, port) do |http|
        http.request(req)
      end
    end

    KLASS = Net::HTTP
  end
end
