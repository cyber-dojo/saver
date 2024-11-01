require_relative '../require_source'
require_source 'externals'

module TestHelpersExternals

  def externals
    @externals ||= Externals.new
  end

  def disk
    externals.disk
  end

  def model
    externals.model
  end

  def prober
    externals.prober
  end

  def random
    externals.random
  end

  def shell
    externals.shell
  end

  #def time
  #  This interferes with MiniTest::Ci
  #  externals.time
  #end

end
