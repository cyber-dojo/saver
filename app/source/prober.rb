# frozen_string_literal: true

class Prober

  def initialize(_externals)
  end

  def sha
    ENV['SHA']
  end

  def alive?
    true
  end

  def ready?
    true
  end

end
