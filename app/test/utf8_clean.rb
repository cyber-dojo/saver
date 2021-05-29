require_relative 'test_base'
require_source 'lib/utf8_clean'

class Utf8CleanTest < TestBase

  def self.id58_prefix
    '3D9'
  end

  test '7FE',
  'cleaned string removes invalid encodings' do
    bad_str = (100..1000).to_a.pack('c*').force_encoding('utf-8')
    refute bad_str.valid_encoding?
    good_str = Utf8::clean(bad_str)
    assert good_str.valid_encoding?
  end

end
