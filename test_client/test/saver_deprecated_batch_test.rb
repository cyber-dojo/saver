
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverDeprecatedBatchTest < TestBase

  def self.hex_prefix
    '76A'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '5E4',
  'batch() runs exists/create/write/append/read commands' do
    expected = []
    commands = []

    dirname = 'client/e3/76/A5'
    commands << ['create',dirname]
    expected << true
    commands << ['exists?',dirname]
    expected << true

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    commands << ['write',there_yes,content]
    expected << true
    commands << ['append',there_yes,content.reverse]
    expected << true

    there_not = dirname + '/there-not.txt'
    commands << ['append',there_not,'nope']
    expected << false

    commands << ['read',there_yes]
    expected << content+content.reverse

    commands << ['read',there_not]
    expected << false

    result = saver.batch(commands)
    assert_equal expected, result
  end

end
