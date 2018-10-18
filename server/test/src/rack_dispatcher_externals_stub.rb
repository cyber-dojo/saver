
class RackDispatcherExternalsStub

  def initialize(stub)
    @stub = stub
  end

  attr_reader :stub

  def grouper
    stub
  end

  def singler
    stub
  end

  def image
    stub
  end

end