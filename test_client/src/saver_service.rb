require_relative 'http'

class SaverService

  def initialize
    @http = Http.new(self, 'saver', 4537)
  end

  def sha
    @http.get
  end

  def ready?
    @http.get
  end

  def exists?(key)
    @http.get(key)
  end

  def make?(key)
    @http.get(key)
  end

  def write(key, value)
    @http.post(key, value)
  end

  def append(key, value)
    @http.post(key, value)
  end

  def read(key)
    @http.get(key)
  end

  def batch_read(keys)
    @http.get(keys)
  end

  def batch_until_false(commands)
    @http.post(commands)
  end

  def batch_until_true(commands)
    @http.post(commands)
  end

end
