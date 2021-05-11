# frozen_string_literal: true
require_relative 'test_base'

class SaverRunAllTest < TestBase

  def self.id58_prefix
    '8EA'
  end

  def id58_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_all()
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '511',
  'run_all() batches new commands' do

    dirname = 'client/run-all/e3/t6/A1'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    command(true, file_create_command(there_yes,content))
    command(true, file_append_command(there_yes,content.reverse))

    there_not = dirname + '/there-not.txt'
    command(false, file_append_command(there_not,'nope'))

    command(content+content.reverse, file_read_command(there_yes))

    command(false, file_read_command(there_not))

    result = saver.run_all(@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # raises when malformed commands

  test '121', %w(
  |when commands is not an Array
  |raise
  ) do
    commands = 23
    message = 'malformed:commands:!Array (Integer):'
    assert_raises_SaverException(message,commands) {
      saver.run_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '122', %w(
  |when commands entry is not an Array
  |raise
  ) do
    commands = [42]
    message = 'malformed:commands[0]:!Array (Integer):'
    assert_raises_SaverException(message,commands) {
      saver.run_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '123', %w(
  |when commands entry is unknown
  |raise
  ) do
    commands = [['hgttg']]
    message = 'malformed:commands[0]:Unknown (hgttg):'
    assert_raises_SaverException(message,commands) {
      saver.run_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '124', %w(
  |when commands entry is incorrect arity
  |raises
  ) do
    commands = [['dir_make','abc/d/e/f'],['file_read',1,2,3,4,5,6]]
    message = 'malformed:commands[1]:file_read!6:'
    assert_raises_SaverException(message,commands) {
      saver.run_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '125', %w(
  |when commands entry has non String parameter
  |raises
  ) do
    commands = [['dir_exists?','abc/d/e/f'],['dir_make',nil]]
    message = 'malformed:commands[1]:dir_make(dirname!=String):'
    assert_raises_SaverException(message,commands) {
      saver.run_all(commands)
    }
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

  # - - - - - - - - - - - - - - - -

  def assert_raises_SaverException(message, commands)
    error = assert_raises(::HttpJsonHash::ServiceError) { yield }
    expected_args = { commands:commands }
    assert_equal expected_args, error.args

    exception = JSON.parse!(error.body)['exception']
    assert_equal message, exception['message'], :message
    assert_equal 'SaverService', exception['class'], :class
    assert_equal JSON.generate(expected_args), exception['body'], :body
  end

end
