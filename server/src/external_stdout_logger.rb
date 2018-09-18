
class ExternalStdoutLogger

  def initialize(_parent)
  end

  def <<(message)
    # prefer p to puts so we get inspect and not to_s
    p message
  end

end