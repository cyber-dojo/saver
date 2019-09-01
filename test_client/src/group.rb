# frozen_string_literal: true

require_relative 'group_v0'
require_relative 'group_v1'
require_relative 'group_v2'
require_relative 'version'

class Group

  def initialize(externals)
    @target = VERSIONS[version].new(externals)
  end

  def method_missing(name, *arguments, &block)
    @target.send(name, *arguments, &block)
  end

  private

  VERSIONS = [ Group_v0, Group_v1, Group_v2 ]

  include Version

end
