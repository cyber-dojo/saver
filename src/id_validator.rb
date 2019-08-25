
class IdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    !grouper.group_exists?(id)
  end

  private

  def grouper
    externals.grouper
  end

  attr_reader :externals

end
