
class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    # eg '0215AFADCB'
    if id.upcase.include?('L')
      false
    else
      dir[id[0..5]].completions == []
    end
  end

  private

  def dir
    @externals.disk
  end

end
