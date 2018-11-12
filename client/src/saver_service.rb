require_relative 'http_json_service'

class SaverService

  def sha
    get(__method__)
  end

  # - - - - - - - - - - - -

  def group_exists?(id)
    get(__method__, id)
  end

  def group_create(manifest)
    post(__method__, manifest)
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

  # - - - - - - - - - - - -

  def kata_exists?(id)
    get(__method__, id)
  end

  def kata_create(manifest)
    post(__method__, manifest)
  end

  def kata_manifest(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def kata_ran_tests(id, index ,files, now, duration, stdout, stderr, status, colour)
    post(__method__, id, index, files, now, duration, stdout, stderr, status, colour)
  end

  def kata_events(id)
    get(__method__, id)
  end

  def kata_event(id, index)
    get(__method__, id, index)
  end

  private

  include HttpJsonService

  def hostname
    'saver'
  end

  def port
    4537
  end

end
