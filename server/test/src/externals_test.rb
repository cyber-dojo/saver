require_relative 'test_base'

class ExternalsTest < TestBase

  def self.hex_prefix
    '7A9'
  end

  # - - - - - - - - - - - - - - - - -

  test '543',
  'default externals are set' do
    externals = Externals.new
    assert_equal 'Grouper',            externals.grouper.class.name
    assert_equal 'ExternalDiskWriter', externals.disk.class.name
    assert_equal 'Image',              externals.image.class.name
    assert_equal 'StorerService',      externals.storer.class.name
    assert_equal 'IdValidator',        externals.id_validator.class.name
  end

end