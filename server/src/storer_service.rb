require_relative 'http_json_service'

class StorerService

  def katas_completed(partial_id)
    get(__method__, partial_id)
  end

  private

  include HttpJsonService

  def hostname
    'storer'
  end

  def port
    4577
  end

end
