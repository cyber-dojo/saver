module Options

  def option_get(id, name)
    fail_unless_known_option(name)
    filename = kata_id_path(id, name)
    result = disk.run(disk.file_read_command(filename))
    if result
      result.lines.last
    else
      {
        'theme' => 'light',
        'colour' => 'on',
        'predict' => 'off',
        'revert_red' => 'off',
        'revert_amber' => 'off',
        'revert_green' => 'off',
        }[name]
    end
  end

  def option_set(id, name, value)
    fail_unless_known_option(name)
    possibles = (name === 'theme') ? ['dark','light'] : ['on', 'off']
    unless possibles.include?(value)
      fail "Cannot set theme to #{value}, only to one of #{possibles}"
    end
    filename = kata_id_path(id, name)
    result = disk.run_all([
      disk.file_create_command(filename, "\n"+value),
      disk.file_append_command(filename, "\n"+value)
    ])
    result
  end

  def default_options
    {
      'theme' => 'light',
      'colour' => 'on',
      'predict' => 'off',
      'revert_red' => 'off',
      'revert_amber' => 'off',
      'revert_green' => 'off',
    }
  end

  def fail_unless_known_option(name)
    unless %w( theme colour predict revert_red revert_amber revert_green ).include?(name)
      fail "Unknown option #{name}"
    end
  end

  KNOWN_KEYS = [
    'theme',
    'fork_button',
    'colour',
    'predict',
    'starting_info_dialog',
    'revert_red',
    'revert_amber',
    'revert_green'
  ]

end
