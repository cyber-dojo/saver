# frozen_string_literal: true

module OptionsChecker

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
    elsif KNOWN_KEYS.include?(key)
      ["on","off"].include?(value)
    else
      false
    end
  end

  KNOWN_KEYS = [
    "theme",
    "fork_button",
    "colour",
    "predict",
    "starting_info_dialog"
  ]

end
