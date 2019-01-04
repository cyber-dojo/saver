
class IdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    if grouper.group_exists?(id)
      false
    elsif ported.ported?(id)
      false
    else
      true
    end
  end

  private

  def grouper
    @externals.grouper
  end

  def ported
    @externals.ported
  end

end
