class Prober

  def alive?
    true
  end

  def ready?
    true
  end

  def sha
    ENV['COMMIT_SHA']
  end

end
