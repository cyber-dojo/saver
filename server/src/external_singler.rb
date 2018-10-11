require_relative 'http_json_service'

class ExternalSingler

  def kata_exists?(id)
    get(__method__, id)
  end

  def kata_create(manifest)
    post(__method__, manifest)
  end

  def kata_manifest(id)
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
