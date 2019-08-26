require_relative 'test_base'

class ExternalsTest < TestBase

  def self.hex_prefix
    '7A9'
  end

  # - - - - - - - - - - - - - - - - -

  test '543',
  'default externals are set' do
    externals = Externals.new
    assert_equal 'Env',             externals.env.class.name
    assert_equal 'Saver',           externals.saver.class.name
    assert_equal 'Group',           externals.group.class.name
    assert_equal 'GroupIdGenerator',externals.group_id_generator.class.name
    assert_equal 'Katas',           externals.katas.class.name
    assert_equal 'KataIdGenerator', externals.kata_id_generator.class.name
  end

end
