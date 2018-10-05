
class IdGeneratorStub

  def initialize
    @stubbed = []
  end

  def stub(*ids)
    @stubbed += ids
  end

  def generate
    if @stubbed == []
      fail RuntimeError, "#{self.class.name} - @stubbed is empty"
    else
      @stubbed.shift
    end
  end

end
