# frozen_string_literal: true
require_relative 'test_base'
require_relative 'saver_service_fake'
require_source 'saver_service'

class SaverRunAllTest < TestBase

  def self.hex_prefix
    '8EA'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_all()
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '511',
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

  multi_test '121', %w(
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

  multi_test '122', %w(
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

  multi_test '123', %w(
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

  multi_test '124', %w(
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

  multi_test '125', %w(
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

  def assert_raises_SaverException(message,commands)
    error = assert_raises(SaverService::Error) { yield }
    json = JSON.parse!(error.message)
    assert_equal '/run_all', json['path'], :path
    expected_body = { 'commands'=>commands }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal message, json['message'], :message
  end

end
