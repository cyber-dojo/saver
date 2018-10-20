
class IdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    if grouper.group_exists?(id)
      false
    elsif storer.katas_completed(id) != []
      false
    else
      true
    end
  end

  private

  def grouper
    @externals.grouper
  end

  def storer
    @externals.storer
  end

end
