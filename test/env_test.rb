require_relative '../src/env'
require_relative 'test_base'

class EnvTest < TestBase

  def self.hex_prefix
    '2A8'
  end

  # - - - - - - - - - - - - - - - - -

  test '190', %w( sha of image's git commit ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  private

  def sha
    Env.new.sha
  end

end
