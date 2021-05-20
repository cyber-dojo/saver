require_relative 'command_checker'

module DiskApi

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # commands

  def dir_exists_command(dirname)
    [ DIR_EXISTS_COMMAND_NAME, dirname ]
  end

  def dir_make_command(dirname)
    [ DIR_MAKE_COMMAND_NAME, dirname ]
  end

  def file_create_command(filename, content)
    [ FILE_CREATE_COMMAND_NAME, filename, content ]
  end

  def file_append_command(filename, content)
    [ FILE_APPEND_COMMAND_NAME, filename, content ]
  end

  def file_read_command(filename)
    [ FILE_READ_COMMAND_NAME, filename ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # primitives

  def assert(command)
    result = run(command)
    if result
      result
    else
      raise "command != true"
    end
  end

  def run(command)
    assert_well_formed_command(command)
    name, *args = command
    {
      DIR_EXISTS_COMMAND_NAME  => -> { dir_exists?(*args) },
      DIR_MAKE_COMMAND_NAME    => -> { dir_make(*args) },
      FILE_CREATE_COMMAND_NAME => -> { file_create(*args) },
      FILE_APPEND_COMMAND_NAME => -> { file_append(*args) },
      FILE_READ_COMMAND_NAME   => -> { file_read(*args) },
    }[name].call()
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # batches

  def assert_all(commands)
    run_until(commands) do |r, index|
      if r
        false
      else
        raise "commands[#{index}] != true"
      end
    end
  end

  def run_all(commands)
    run_until(commands) { |r| r === :never }
  end

  def run_until_true(commands)
    run_until(commands) { |r| r }
  end

  def run_until_false(commands)
    run_until(commands) { |r| !r }
  end

  private

  include CommandChecker

  DIR_EXISTS_COMMAND_NAME = 'dir_exists?'
  DIR_MAKE_COMMAND_NAME   = 'dir_make'

  FILE_CREATE_COMMAND_NAME = 'file_create'
  FILE_APPEND_COMMAND_NAME = 'file_append'
  FILE_READ_COMMAND_NAME   = 'file_read'

  def run_until(commands, &block)
    assert_well_formed_commands(commands)
    results = []
    commands.each.with_index(0) do |command, index|
      result = run(command)
      results << result
      if block.call(result, index)
        break
      end
    end
    results
  end

end
