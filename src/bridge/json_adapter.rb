# frozen_string_literal: true

require 'json'

module JsonAdapter

  def json_plain(o)
    JSON.fast_generate(o)
  end

  def json_parse(s)
    JSON.parse!(s)
  end

end
