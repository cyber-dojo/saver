# frozen_string_literal: true

require_relative 'kata_v1'
require_relative 'kata_v2'
require_relative 'version'

class Kata

  def initialize(externals)
    @target = VERSIONS[version].new(externals)
  end

  def method_missing(name, *arguments, &block)
    @target.send(name, *arguments, &block)
  end

  private

  VERSIONS = [ nil, Kata_v1, Kata_v2 ]

  include Version

end
