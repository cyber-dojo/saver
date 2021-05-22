class Prober

  def initialize(externals)
    @externals = externals
  end

  def sha
    '"' + ENV['SHA'] + '"'
  end

  def alive?
    true
  end

  def ready?
    custom_start_points.ready? && saver.ready?
  end

  private

  def custom_start_points
    @externals.custom_start_points
  end

  def saver
    @externals.saver
  end

end
