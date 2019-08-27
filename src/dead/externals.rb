require_relative 'saver'

class Externals

  def saver
    @saver ||= Saver.new
  end

end
