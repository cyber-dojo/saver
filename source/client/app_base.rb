require 'sinatra/base'
require 'json'

class AppBase < Sinatra::Base

  set :port, ENV['PORT']
  set :host_authorization, { permitted_hosts: [] } # https://github.com/sinatra/sinatra/issues/2065#issuecomment-2484285707

  def initialize(externals)
    @externals = externals
    super(nil)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.get_json(name, klass)
    get "/#{name}", provides:[:json] do
      target = klass.new(@externals)
      result = target.public_send(name)
      content_type :json
      { name.to_s => result }.to_json
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

end
