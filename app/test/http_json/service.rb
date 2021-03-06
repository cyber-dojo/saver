require_relative 'requester'
require_relative 'unpacker'

module HttpJson

  def self.service(name, http, hostname, port)
    requester = Requester.new(http, hostname, port)
    Unpacker.new(requester)
  end

end
