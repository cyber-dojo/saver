
class IdGeneratorStub

  def initialize
    @stubbed = []
  end

  def stub(*ids)
    @stubbed = ids
  end

  def generate
    @stubbed.shift
  end

end
