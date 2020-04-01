require_relative 'test_base'
require_relative '../src/saver'

class SaverBatchTest < TestBase

  def self.hex_prefix
    '34F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '514',
  'batch() runs all its commands, not stopping if any return false' do
    expected = []
    commands = []

    dirname = 'batch/e3/t6/A8'
    commands << ['create',dirname]
    expected << true

    commands << ['exists?',dirname]
    expected << true

    there_no = dirname + '/there-not.txt'
    commands << ['read',there_no]
    expected << false

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    commands << ['write',there_yes,content]
    expected << true

    commands << ['append',there_yes,content.reverse]
    expected << true

    commands << ['read',there_yes]
    expected << content+content.reverse

    commands << ['read',there_no]
    expected << false

    result = saver.batch(commands)
    assert_equal expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '515',
  'batch_until_false() runs its commands, stopping at the first one that returns false' do
    expected = []
    commands = []

    dirname = 'batch/x3/t5/A7'
    commands << ['create',dirname]
    expected << true

    commands << ['exists?',dirname]
    expected << true

    there_no = dirname + '/there-not.txt'
    commands << ['read',there_no]
    expected << false <------

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    commands << ['write',there_yes,content] # true
    commands << ['append',there_yes,content.reverse] # true
    commands << ['read',there_yes] # true
    commands << ['read',there_no] # false

    result = saver.batch_until_false(commands)
    assert_equal expected, result
  end

end