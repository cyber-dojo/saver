
class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    !grouper.id?(id) && !id.upcase.include?('L')
  end

  private

  def grouper
    @externals.grouper
  end

end
