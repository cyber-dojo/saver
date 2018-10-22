require_relative '../../src/image'
require_relative 'test_base'

class ImageTest < TestBase

  def self.hex_prefix
    '2A8'
  end

  def sha
    Image.new(externals.disk).sha
  end

  # - - - - - - - - - - - - - - - - -

  test '190', %w( sha of image's git commit ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

end