# frozen_string_literal: true
require 'oj'  # fast JSON gem

module OjAdapter # mix-in

  def json_plain(obj)
    Oj.dump(obj, { :mode => :strict })
  end

  def json_pretty(obj)
    Oj.generate(obj, OJ_PRETTY_OPTIONS)
  end

  def json_parse(s)
    Oj.strict_load(s)
  end

  OJ_PRETTY_OPTIONS = {
    :space => ' ',
    :indent => '  ',
    :object_nl => "\n",
    :array_nl => "\n"
  }

end
