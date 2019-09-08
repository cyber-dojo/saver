# frozen_string_literal: true

require 'oj'

module OjAdapter # mix-in

  def json_plain(obj)
    Oj.dump(obj, { :mode => :strict })
  end

  def json_parse(s)
    Oj.strict_load(s)
  end

end
