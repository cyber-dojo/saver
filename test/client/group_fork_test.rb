require_relative 'test_base'

class GroupForkTest < TestBase

  versions_test 'SP6860', %w(
  | group_fork succeeding
  ) do
    gid = group_fork('5rTJv5', 1)
    assert group_exists?(gid)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'SP6861', %w(
  | group_fork failing
  ) do
    assert_raises { group_fork('111222',0) }
  end

end
