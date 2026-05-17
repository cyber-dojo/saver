require_relative '../no_longer_implemented_error'

module LegacyWriteGuard
  private

  def assert_write_allowed
    unless @externals.allow_legacy_writes?
      fail NoLongerImplementedError, "#{self.class}: write not supported"
    end
  end
end
