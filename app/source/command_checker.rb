# frozen_string_literal: true
require_relative 'http_json/request_error'

module CommandChecker

  def assert_well_formed_command(command)
    if command.nil?
      fail missing('command')
    end
    unless command.is_a?(Array)
      fail malformed('command', "!Array (#{command.class.name})")
    end
    fail_unless_well_formed_command(command,'')
  end

  # - - - - - - - - - - - - - - -

  def assert_well_formed_commands(commands)
    if commands.nil?
      fail missing('commands')
    end
    unless commands.is_a?(Array)
      fail malformed('commands', "!Array (#{commands.class.name})")
    end
    commands.each.with_index do |command, index|
      unless command.is_a?(Array)
        fail malformed("commands[#{index}]", "!Array (#{command.class.name})")
      end
      fail_unless_well_formed_command(command,"s[#{index}]")
    end
  end

  # - - - - - - - - - - - - - - -

  def fail_unless_well_formed_command(command, index)
    name = command[0]
    unless name.is_a?(String)
      fail malformed("command#{index}[0]", "!String (#{name.class.name})")
    end
    case name
    when 'dir_exists?' then fail_unless_well_formed_args(command, index, 'dirname')
    when 'dir_make'    then fail_unless_well_formed_args(command, index, 'dirname')
    when 'file_create' then fail_unless_well_formed_args(command, index, 'filename', 'content')
    when 'file_append' then fail_unless_well_formed_args(command, index, 'filename', 'content')
    when 'file_read'   then fail_unless_well_formed_args(command, index, 'filename')
    else
      fail malformed("command#{index}", "Unknown (#{name})")
    end
  end

  # - - - - - - - - - - - - - - -

  def fail_unless_well_formed_args(command, index, *arg_names)
    name,*args = command
    arity = arg_names.size
    unless args.size === arity
      fail malformed("command#{index}", "#{name}!#{args.size}")
    end
    arity.times do |n|
      arg = args[n]
      arg_name = arg_names[n]
      unless arg.is_a?(String)
        fail malformed("command#{index}", "#{name}(#{arg_name}!=String)")
      end
    end
  end

  # - - - - - - - - - - - - - - - -

  def missing(arg_name)
    HttpJson::RequestError.new("missing:#{arg_name}:")
  end

  def malformed(arg_name, message)
    HttpJson::RequestError.new("malformed:#{arg_name}:#{message}:")
  end

end
