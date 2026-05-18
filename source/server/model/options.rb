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

end
