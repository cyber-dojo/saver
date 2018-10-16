require_relative 'http_json_service'

class StorerService

  def kata_exists?(kata_id)
    get(__method__, kata_id)
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
