require 'json'
require 'net/http'

module HttpJsonService # mix-in

  def get(args, method)
    name = method.to_s
    json = http(name, jsoned_args(name, args)) { |uri|
      Net::HTTP::Get.new(uri)
    }
    result(json, name)
  end

  def http(method, args)
    uri = URI.parse("http://#{hostname}:#{port}/#{method}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = yield uri.request_uri
    request.content_type = 'application/json'
    request.body = args
    response = http.request(request)
    JSON.parse(response.body)
  end

  def jsoned_args(method, args)
    parameters = self.class.instance_method(method).parameters
    Hash[parameters.map.with_index { |parameter,index|
      [parameter[1], args[index]]
    }].to_json
  end

  def result(json, name)
    json[name]
  end

end