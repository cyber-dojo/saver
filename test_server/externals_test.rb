require_relative 'test_base'

class ExternalsTest < TestBase

  def self.hex_prefix
    '7A9'
  end

  # - - - - - - - - - - - - - - - - -

  test '543',
  'default externals are set' do
    externals = Externals.new
    assert_equal 'Grouper',         externals.grouper.class.name
    assert_equal 'ExternalDisk',    externals.disk.class.name
    assert_equal 'Env',             externals.env.class.name
    assert_equal 'IdValidator',     externals.id_validator.class.name
    assert_equal 'ExternalMapper',  externals.mapper.class.name
  end

end