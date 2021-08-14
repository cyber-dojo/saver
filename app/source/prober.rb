class Prober

  def initialize(externals)
    @externals = externals
  end

  def sha
    ENV['SHA']
  end

  def alive?
    true
  end

  def ready?
    start_points = [custom_start_points, exercises_start_points, languages_start_points]
    start_points.all?(&:ready?)
  end

  private

  def custom_start_points
    @externals.custom_start_points
  end

  def exercises_start_points
    @externals.exercises_start_points
  end

  def languages_start_points
    @externals.languages_start_points
  end

end
