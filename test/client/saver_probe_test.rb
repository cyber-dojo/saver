require_relative 'test_base'
require_source 'prober'

class SaverProbeTest < TestBase

  def self.id58_prefix
    '6E3'
  end

  test '602',
  %w( alive? is always true ) do
    assert prober.alive?
  end

  test '603',
  %w( ready? is always true ) do
    assert prober.ready?
  end

  test '604', %w( sha is sha of image's git commit ) do
    sha = prober.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  test '605',
  %w( base_image is sinatra-base ) do
    base_image = prober.base_image
    assert base_image.include?("sinatra-base"), base_image
  end

  private

  def prober
    Prober.new(externals)
  end

end
