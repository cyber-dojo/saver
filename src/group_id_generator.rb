require_relative 'base58'

class GroupIdGenerator

  def initialize(externals)
    @externals = externals
  end

  def id
    loop do
      id = Base58.string(6)
      unless group.group_exists?(id)
        return id
      end
    end
  end

  private

  def group
    @externals.group
  end

end
