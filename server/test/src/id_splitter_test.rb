require_relative 'test_base'
require_relative '../../src/id_splitter'

class IdSplitterTest < TestBase

  def self.hex_prefix
    '5B930'
  end

  include IdSplitter

  # - - - - - - - - - - - - - - - - -

  test '045',
  'outer(id) is first 2 characters' do
    id = '05FB53EF05'
    assert_equal '05', outer(id)
    assert_equal 2, outer(id).length
  end

  test '046',
  'inner(id) is last 8 characters' do
    id = '99AE1E6E19'
    assert_equal 'AE1E6E19', inner(id)
    assert_equal 8, inner(id).length
  end

  test '047',
  'outer(id)+inner(id) == id' do
    id = '549A9CB59A'
    assert_equal id, outer(id)+inner(id)
  end
end