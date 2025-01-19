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

  def base_image
    ENV['BASE_IMAGE']
  end

end
