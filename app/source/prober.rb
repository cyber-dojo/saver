# frozen_string_literal: true

class Prober

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
