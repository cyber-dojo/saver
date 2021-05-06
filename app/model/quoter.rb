# frozen_string_literal: true

module Quoter

  def quoted(o)
    '"' + o.to_s + '"'
  end

  def unquoted(s)
    s[1..-2]
  end

end

