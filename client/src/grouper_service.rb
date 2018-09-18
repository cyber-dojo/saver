require_relative 'http_json_service'

class GrouperService

  def sha
    get(__method__)
  end

  # - - - - - - - - - - - -

  def create(manifest)
    post(__method__, manifest)
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

  def join(id)
    post(__method__, id)
  end

  def joined(id)
    post(__method__, id)
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
