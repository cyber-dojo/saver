require_relative 'rack_dispatcher_stub'

module RackDispatcherExternalsStub

  def grouper
    stub
  end

  def singler
    stub
  end

  def image
    stub
  end

  def stub
    RackDispatcherStub.new
  end

end