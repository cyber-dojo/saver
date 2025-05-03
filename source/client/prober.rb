class Prober

  def initialize(externals)
    @externals = externals
  end

  def alive?
    true
  end

  def ready?
    saver.ready?
  end

  def sha
    saver.sha
  end

  private

  def saver
    @externals.saver
  end

end
