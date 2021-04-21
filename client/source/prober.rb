# frozen_string_literal: true

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
    saver.ready?
  end

  private

  def saver
    @externals.saver
  end

end
