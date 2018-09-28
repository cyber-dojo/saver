require_relative 'http_json_service'

class GrouperService

  def sha
    get(__method__)
  end

  # - - - - - - - - - - - -

  def create(manifest, files)
    post(__method__, manifest, files)
  end

  def manifest(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def id?(id)
    get(__method__, id)
  end

  def id_completed(partial_id)
    get(__method__, partial_id)
  end

  def id_completions(outer_id)
    get(__method__, outer_id)
  end

  # - - - - - - - - - - - -

  def join(id, indexes)
    post(__method__, id, indexes)
  end

  def joined(id)
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
