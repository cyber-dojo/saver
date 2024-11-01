require_relative 'test_base'

class KataForkTest < TestBase

  def self.id58_prefix
    'Rg3'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '860', %w(
  |kata_fork succeeding
  ) do
    kid = kata_fork('5rTJv5', 1)
    assert kata_exists?(kid)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '861', %w(
  |kata_fork failing
  ) do
    assert_raises { kata_fork('111222',0) }
  end

end
