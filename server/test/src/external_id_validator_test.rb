require_relative 'test_base'

class ExternalIdValidatorTest < TestBase

  def self.hex_prefix
    'C72E3'
  end

  def hex_setup
    @real_id_generator = externals.id_generator
    @stub_id_generator = IdGeneratorStub.new
    externals.id_generator = @stub_id_generator
  end

  def hex_teardown
    externals.id_generator = @real_id_generator
  end

  attr_reader :stub_id_generator

  # - - - - - - - - - - - - - - - - - - - - - - -
  # valid?(id)
  # - - - - - - - - - - - - - - - - - - - - - - -

  test '921',
  'false when initial 6-chars already used for existing id' do
    id = '82875424E7'
    stub_create(id)
    partial_id = id[0..6]
    refute_valid(partial_id + '0000')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '922',
  'false if id contains ell (lowercase or uppercase)' do
    ell = 'L'
    refute_valid('2466FD900' + ell.upcase)
    refute_valid('2466FD900' + ell.downcase)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '923',
  'true when initial 6-chars not yet used for existing id' do
    id = 'D9A3DC94C6'
    assert_valid(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # completions(id)
  #- - - - - - - - - - - - - - - - - - - - - -

  test '396',
  'id_completions when no completions' do
    assert_equal [], completions('AD8FFE0')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '397',
  'id_completions when a single completion' do
    disk["#{path}/7C/A8A87A2B"].make
    assert_equal ["#{path}/7C/A8A87A2B"], completions('7CA8A8')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '398',
  'id_completions when two completions' do
    disk["#{path}/22/3D2D0000"].make
    disk["#{path}/22/3D2D9999"].make
    expected = [ "#{path}/22/3D2D0000", "#{path}/22/3D2D9999" ]
    assert_equal expected.sort, completions('223D2D').sort
  end

  private

  def disk
    @externals.disk
  end

  def id_validator
    @externals.id_validator
  end

  def path
    grouper.path
  end

  def completions(id)
    id_validator.completions(id)
  end

  def assert_valid(id)
    assert id_validator.valid?(id)
  end

  def refute_valid(id)
    refute id_validator.valid?(id)
  end

end
