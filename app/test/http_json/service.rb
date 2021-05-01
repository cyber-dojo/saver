# frozen_string_literal: true
require_relative 'request_packer'
require_relative 'response_unpacker'

module HttpJson

  def self.service(name, http, hostname, port)
    requester = RequestPacker.new(http, hostname, port)
    ResponseUnpacker.new(name, requester)
  end

end
