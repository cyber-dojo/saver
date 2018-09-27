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
    manifest = create_manifest
    json = { manifest:manifest }.to_json
    assert_equal manifest, WellFormedArgs.new(json).manifest
    manifest['filename_extension'] = '.c'
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
    bad_time = [2018,-3,28, 11,33,13]
    [
      [],                                                # ! Hash
      {},                                                # required key missing
      create_manifest.merge({x:'unknown'}),              # unknown key
      create_manifest.merge({display_name:42}),          # ! String
      create_manifest.merge({image_name:42}),            # ! String
      create_manifest.merge({runner_choice:42}),         # ! String
      create_manifest.merge({filename_extension:true}),  # ! String && ! Array
      create_manifest.merge({filename_extension:{}}),    # ! String && ! Array
      create_manifest.merge({exercise:true}),            # ! String
      create_manifest.merge({visible_files:[]}),         # ! Hash
      create_manifest.merge({visible_files:{
        'cyber-dojo.sh':42                     # file content must be String
      }}),
      create_manifest.merge({highlight_filenames:1}),    # ! Array of Strings
      create_manifest.merge({highlight_filenames:[1]}),  # ! Array of Strings
      create_manifest.merge({progress_regexs:{}}),       # ! Array of Strings
      create_manifest.merge({progress_regexs:[1]}),      # ! Array of Strings
      create_manifest.merge({tab_size:true}),            # ! Integer
      create_manifest.merge({max_seconds:nil}),          # ! Integer
      create_manifest.merge({created:nil}),              # ! Array of 6 Integers
      create_manifest.merge({created:['s']}),            # ! Array of 6 Integers
      create_manifest.merge({created:bad_time}),         # ! Time
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
      'ABCDEF123='  # ! Base56 chars
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
      '=',   # ! Base56 String
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
      '=',      # ! Base56 String
      'abc'     # ! length 6..10
    ]
  end

end