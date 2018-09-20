require_relative 'http_json_service'

class ExternalSingler

  def create(manifest)
    post(__method__, manifest)
  end

  # - - - - - - - - - - - -

  def id?(id)
    get(__method__, id)
  end

  private

  include HttpJsonService

  def hostname
    'singler'
  end

  def port
    4517
  end

end
