
class IdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    if grouper.group_exists?(id)
      false
    else
      true
    end
  end

  private

  def grouper
    @externals.grouper
  end

end
