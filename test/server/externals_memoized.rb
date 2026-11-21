require_relative 'test_base'

class ExternalsMemoizedTest < TestBase

  test 'Mx7Eq1', %w(
  | differ is made once per externals, so every diff shares one differ
  ) do
    assert_same externals.differ, externals.differ
  end

end
