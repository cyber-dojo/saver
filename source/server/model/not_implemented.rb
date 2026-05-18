require_relative '../no_longer_implemented_error'

module NotImplemented
  private

  def raise_not_implemented
    fail NoLongerImplementedError, "#{self.class}: write not supported"
  end
end
