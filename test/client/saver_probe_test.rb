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

  private

  def prober
    Prober.new(externals)
  end

end
