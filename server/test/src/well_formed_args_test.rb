require_relative 'test_base'
require_relative '../../src/well_formed_args'

class WellFormedArgsTest < TestBase

  def self.hex_prefix
    '0A0C4'
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
    manifest = starter.manifest
    json = { manifest:manifest }.to_json
    assert_equal manifest, WellFormedArgs.new(json).manifest
  end

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
      starter.manifest.merge({x:false}),                  # unknown key
      starter.manifest.merge({display_name:42}),          # ! String
      starter.manifest.merge({image_name:42}),            # ! String
      starter.manifest.merge({runner_choice:42}),         # ! String
      starter.manifest.merge({filename_extension:true}),  # ! String && ! Array
      starter.manifest.merge({filename_extension:{}}),    # ! String && ! Array
      starter.manifest.merge({exercise:true}),            # ! String
      starter.manifest.merge({highlight_filenames:1}),    # ! Array of Strings
      starter.manifest.merge({highlight_filenames:[1]}),  # ! Array of Strings
      starter.manifest.merge({progress_regexs:{}}),       # ! Array of Strings
      starter.manifest.merge({progress_regexs:[1]}),      # ! Array of Strings
      starter.manifest.merge({tab_size:true}),       # ! Integer
      starter.manifest.merge({max_seconds:nil}),     # ! Integer
      starter.manifest.merge({created:nil}),         # ! Array of 6 Integers
      starter.manifest.merge({created:['s']}),       # ! Array of 6 Integers
      starter.manifest.merge({created:bad_month}),   # ! Time
      starter.manifest.merge({created:bad_year}),    # ! Time
      starter.manifest.merge({id:'df=sdf=sdf'}),     # ! Base58.string
      starter.manifest.merge({id:'ABCDEFGHI'}),      # ! 10-chars long
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # files
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '846',
  'files does not raise when well-formed' do
    files = { 'cyber-dojo.sh' => 'make' }
    json = { files:files }.to_json
    assert_equal files, WellFormedArgs.new(json).files
  end

  test '847',
  'files raises when malformed' do
    expected = 'files:malformed'
    malformed_files.each do |malformed|
      json = { files:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.files }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_files
    [
      [],              # ! Hash
      { "x" => 42 },   # content ! String
      { "y" => true }, # content ! String
      { "z" => nil },  # content ! String
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '61A',
  'id does not raise when well-formed' do
    id = 'A1B2F345kn'
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
      '',           # ! 10 chars
      '34',         # ! 10 chars
      '345',        # ! 10 chars
      '123456789',  # ! 10 chars
      'ABCDEF123='  # ! Base58 chars
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # outer_id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C6B',
  'outer_id does not raise when well-formed' do
    outer_id = '12'
    json = { outer_id:outer_id }.to_json
    assert_equal outer_id, WellFormedArgs.new(json).outer_id
  end

  test 'CB7',
  'outer_id raises when malformed' do
    expected = 'outer_id:malformed'
    malformed_outer_ids.each do |malformed|
      json = { outer_id:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.outer_id }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_outer_ids
    [
      true,  # ! String
      '=',   # ! Base58 String
      '123', # ! length 2
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # partial_id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FC1',
  'partial_id does not raise when well-formed' do
    partial_id = '1a34Z6'
    json = { partial_id:partial_id }.to_json
    assert_equal partial_id, WellFormedArgs.new(json).partial_id
  end

  test 'FC2',
  'partial_id raises when malformed' do
    expected = 'partial_id:malformed'
    malformed_partial_ids.each do |malformed|
      json = { partial_id:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.partial_id }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_partial_ids
    [
      false,    # ! String
      '=',      # ! Base58 String
      'abc'     # ! length 6..10
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