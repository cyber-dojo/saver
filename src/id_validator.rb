
class IdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    if grouper.group_exists?(id)
      false
    elsif mapper.mapped?(id)
      false
    else
      true
    end
  end

  private

  def grouper
    @externals.grouper
  end

  def mapper
    @externals.mapper
  end

end
