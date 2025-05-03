class Prober

  def alive?
    true
  end

  def ready?
    true
  end

  def sha
    ENV['SHA']
  end

end
