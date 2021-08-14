require_relative 'test_base'

class CustomStartPointsTest < TestBase

  def self.id58_prefix
    '9F2'
  end

  test '2C6', 'ready?' do
    assert custom_start_points.ready?
  end

  test '2C7', 'display_names' do
    actual = custom_start_points.display_names
    assert actual.is_a?(Array)
    assert actual.size > 0
  end

  test '2C9', 'manifest' do
    display_name = custom_start_points.display_names[0]
    manifest = custom_start_points.manifest(display_name)
    assert manifest.is_a?(Hash)
  end

end
