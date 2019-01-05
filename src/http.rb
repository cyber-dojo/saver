require_relative 'service_error'
require 'json'
require 'net/http'

class Http

  def initialize(parent, hostname, port)
    @parent = parent
    @hostname = hostname
    @port = port
  end

  def get(*args)
    name = name_of(caller)
    json = request(name, args_hash(name, *args)) { |url|
      Net::HTTP::Get.new(url)
    }
    response(json, name)
  end

  private

  attr_reader :parent, :hostname, :port

  def name_of(caller)
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  def request(path, named_args)
    url = URI.parse("http://#{hostname}:#{port}/#{path}")
    req = yield url
    req.content_type = 'application/json'
    req.body = named_args.to_json
    service = Net::HTTP.new(url.host, url.port)
    response = service.request(req)
    JSON.parse(response.body)
  end

  def response(json, method)
    fail_unless(method, 'bad json') { json.class.name == 'Hash' }
    exception = json['exception']
    fail_unless(method, pretty(exception)) { exception.nil? }
    fail_unless(method, 'no key') { json.key?(method) }
    json[method]
  end

  def args_hash(method, *args)
    # Uses reflection to create a hash of args where each key is
    # the parameter name. For example, differ_services does this
    #
    #   def diff(was_files, now_files)
    #     http.get(__method__, was_files, now_files)
    #  end
    #
    # Reflection sees the names of diff()'s parameters are
    # 'was_files' and 'now_files' and so constructs the hash
    # { 'was_files' => args[0], 'now_files' => args[1] }
    parameters = parent.class.instance_method(method).parameters
    parameters.map
              .with_index { |parameter,index| [parameter[1], args[index]] }
              .to_h
  end

  def fail_unless(name, message, &block)
    unless block.call
      fail ServiceError.new(parent.class.name, name, message)
    end
  end

  def pretty(json)
    JSON.pretty_generate(json)
  end

end
