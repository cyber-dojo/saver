
class RackDispatcherExternalsStub

  def initialize(stub)
    @stub = stub
  end

  attr_reader :stub

  def env
    stub
  end

  def grouper
    stub
  end

  def singler
    stub
  end

end
