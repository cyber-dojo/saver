require_relative 'http_json_service'

class GrouperService

  def sha
    get(__method__)
  end

  # - - - - - - - - - - - -

  def group_exists?(id)
    get(__method__, id)
  end

  def group_create(manifest, files)
    post(__method__, manifest, files)
  end

  def group_manifest(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def group_join(id, indexes)
    post(__method__, id, indexes)
  end

  def group_joined(id)
    get(__method__, id)
  end

  private

  include HttpJsonService

  def hostname
    'grouper'
  end

  def port
    4537
  end

end
