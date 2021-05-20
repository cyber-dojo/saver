require_relative 'test_base'

class ProbingTest < TestBase

  def self.id58_prefix
    'AEA'
  end

  test '190', %w( sha is sha of image's git commit ) do
    sha = prober.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  test '602',
  %w( ready? is always true ) do
    assert prober.ready?
  end

  test '603',
  %w( alive? is always true ) do
    assert prober.alive?
  end

end
