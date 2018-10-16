require_relative 'http_json_service'

class StorerService


  private

  include HttpJsonService

  def hostname
    'storer'
  end

  def port
    4577
  end

end
