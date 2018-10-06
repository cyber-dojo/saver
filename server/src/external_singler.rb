require_relative 'http_json_service'

class ExternalSingler

  def exists?(id)
    get(__method__, id)
  end

  def create(manifest, files)
    post(__method__, manifest, files)
  end

  def manifest(id)
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
