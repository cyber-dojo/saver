require_relative 'test_base'
require_relative '../../src/well_formed_args'

class WellFormedArgsTest < TestBase

  def self.hex_prefix
    '0A1'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # c'tor
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A04',
  'ctor raises when its string arg is not valid json' do
    expected = 'json:malformed'
    # abc is not a valid top-level json element
    error = assert_raises { WellFormedArgs.new('abc') }
    assert_equal expected, error.message
    # nil is null in json
    error = assert_raises { WellFormedArgs.new('{"x":nil}') }
    assert_equal expected, error.message
    # keys have to be strings in json
    error = assert_raises { WellFormedArgs.new('{42:"answer"}') }
    assert_equal expected, error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '591',
  'manifest does not raise when well-formed' do
    well_formed_manifests.each do |manifest|
      json = { manifest:manifest }.to_json
      WellFormedArgs.new(json).manifest
    end
  end

  def well_formed_manifests
    [
      starter_manifest,
      starter_manifest.merge({filename_extension:'.h'}),
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '592',
  'manifest raises when malformed' do
    malformed_manifests.each do |malformed|
      json = { manifest:malformed }.to_json
      error = assert_raises {
        WellFormedArgs.new(json).manifest
      }
      assert_equal 'manifest:malformed', error.message, malformed
    end
  end

  def malformed_manifests
    bad_month = [2018,-3,28, 11,33,13]
    bad_year = ["2018",3,28, 11,33,13]
    [
      [],                                                 # ! Hash
      {},                                                 # required key missing
      starter_manifest.merge({x:false}),                  # unknown key
      starter_manifest.merge({files:[]}),                 # ! Hash
      starter_manifest.merge({files:{'s' => [4]}}),       # ! Hash{s->s}
      starter_manifest.merge({display_name:42}),          # ! String
      starter_manifest.merge({image_name:42}),            # ! String
      starter_manifest.merge({runner_choice:42}),         # ! String
      starter_manifest.merge({filename_extension:true}),  # ! String && ! Array
      starter_manifest.merge({filename_extension:{}}),    # ! String && ! Array
      starter_manifest.merge({filename_extension:[23]}),  # ! Array[String]
      starter_manifest.merge({exercise:true}),            # ! String
      starter_manifest.merge({highlight_filenames:1}),    # ! Array of Strings
      starter_manifest.merge({highlight_filenames:[1]}),  # ! Array of Strings
      starter_manifest.merge({progress_regexs:{}}),       # ! Array of Strings
      starter_manifest.merge({progress_regexs:[1]}),      # ! Array of Strings
      starter_manifest.merge({tab_size:true}),       # ! Integer
      starter_manifest.merge({max_seconds:nil}),     # ! Integer
      starter_manifest.merge({created:nil}),         # ! Array of 6 Integers
      starter_manifest.merge({created:['s']}),       # ! Array of 6 Integers
      starter_manifest.merge({created:bad_month}),   # ! Time
      starter_manifest.merge({created:bad_year}),    # ! Time
      starter_manifest.merge({id:true}),             # ! string
      starter_manifest.merge({id:'df=sdf=sdf'}),     # ! Base58.string
      starter_manifest.merge({id:'12345'}),          # ! 6-chars long
    ]
  end

  def starter_manifest
    manifest = starter.manifest
    manifest[:files] = starter.files
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '61A',
  'id does not raise when well-formed' do
    id = 'A1B2kn'
    json = { id:id }.to_json
    assert_equal id, WellFormedArgs.new(json).id
  end

  test '61B',
  'id raises when malformed' do
    expected = 'id:malformed'
    malformed_ids.each do |malformed|
      json = { id:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.id }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_ids
    [
      nil,          # ! String
      [],           # ! string
      '',           # ! 6 chars
      '12',         # ! 6 chars
      '12345',      # ! 6 chars
      '1234567',    # ! 6 chars
      '12345='      # ! Base58 chars
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # indexes
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '086',
  'indexes does not raise when well-formed' do
    json = { indexes:(0..63).to_a }.to_json
    WellFormedArgs.new(json).indexes
  end

  test '087',
  'indexes raises when malformed' do
    expected = 'indexes:malformed'
    malformed_indexes.each do |malformed|
      json = { indexes:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.indexes }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_indexes
    [
      42,
      "string",
      false,
      {},
      [],
      [0,1],
      [62,63],
      (1..64).to_a
    ]
  end

end