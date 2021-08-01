require_relative 'test_base'

class GroupForkTest < TestBase

  def self.id58_prefix
    'SP6'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '860', %w(
  |group_fork succeeding
  ) do
    gid = group_fork('5rTJv5', 1)
    assert group_exists?(gid)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '861', %w(
  |group_fork failing
  ) do
    assert_raises { group_fork('111222',0) }
  end

end
