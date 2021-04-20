# frozen_string_literal: true


module DiskCore # mixin

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

  def assert(command:)
    result = run(command:command)
    if result
      result
    else
      raise "command != true"
    end
  end

  def run(command:)
    name, *args = command
    case name
    when DIR_EXISTS_COMMAND_NAME  then dir_exists?(*args)
    when DIR_MAKE_COMMAND_NAME    then dir_make(*args)
    when FILE_CREATE_COMMAND_NAME then file_create(*args)
    when FILE_APPEND_COMMAND_NAME then file_append(*args)
    when FILE_READ_COMMAND_NAME   then file_read(*args)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # batches

  def assert_all(commands:)
    run_until(commands) do |r, index|
      if r
        false
      else
        raise "commands[#{index}] != true"
      end
    end
  end

  def run_all(commands:)
    run_until(commands) { |r| r === :never }
  end

  def run_until_true(commands:)
    run_until(commands) { |r| r }
  end

  def run_until_false(commands:)
    run_until(commands) { |r| !r }
  end

  private

  DIR_EXISTS_COMMAND_NAME = 'dir_exists?'
  DIR_MAKE_COMMAND_NAME   = 'dir_make'

  FILE_CREATE_COMMAND_NAME = 'file_create'
  FILE_APPEND_COMMAND_NAME = 'file_append'
  FILE_READ_COMMAND_NAME   = 'file_read'

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_until(commands, &block)
    results = []
    commands.each.with_index(0) do |command, index|
      result = run(command:command)
      results << result
      if block.call(result, index)
        break
      end
    end
    results
  end

end
