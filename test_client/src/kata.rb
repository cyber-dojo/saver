# frozen_string_literal: true

require_relative 'kata_v0'
require_relative 'kata_v1'
require_relative 'kata_v2'

class Kata

  def initialize(externals)
    @target = target(externals)
  end

  def method_missing(name, *arguments, &block)
    @target.send(name, *arguments, &block)
  end

  private

  def target(externals)
    name = ENV['CYBER_DOJO_TEST_NAME']
    if v_test?(name,0)
      Kata_v0.new(externals)
    elsif v_test?(name,1)
      Kata_v1.new(externals)
    else
      Kata_v2.new(externals)
    end
  end

  def v_test?(name,n)
    name.start_with?("<version=#{n.to_s}>")
  end

end
