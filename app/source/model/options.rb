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

  def fail_unless_known_option(name)
    unless %w( theme colour predict revert_red revert_amber revert_green ).include?(name)
      fail "Unknown option #{name}"
    end
  end

  def fail_unless_known_options(options)
    unless options.is_a?(Hash)
      fail "options is not a Hash"
    end
    options.each do |key,value|
      unless known_option_key?(key)
        fail "options:{#{quoted(key)}: #{value}} unknown key: #{quoted(key)}"
      end
      unless known_option_value?(key, value)
        fail "options:{#{quoted(key)}: #{value}} unknown value: #{value}"
      end
    end
  end

  def known_option_key?(key)
    key.is_a?(String) && KNOWN_KEYS.include?(key)
  end

  def known_option_value?(key, value)
    if key === "theme"
      ["dark","light"].include?(value)
    else
      ["on","off"].include?(value)
    end
  end

  def quoted(s)
    '"' + s + '"'
  end

  KNOWN_KEYS = [
    "theme",
    "fork_button",
    "colour",
    "predict",
    "starting_info_dialog"
  ]

end
