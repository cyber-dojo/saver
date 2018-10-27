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
      starter.manifest,
      starter.manifest.merge({filename_extension:'.h'}),
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '593',
  'manifest raises when required key is missing' do
    manifest = starter.manifest
    manifest.delete('display_name')
    json = { manifest:manifest }.to_json
    error = assert_raises(ClientError) {
      WellFormedArgs.new(json).manifest
    }
    assert_equal 'malformed:manifest:missing key[display_name]', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '594',
  'manifest raises when unknown key exists' do
    manifest = starter.manifest
    manifest['x'] = false
    json = { manifest:manifest }.to_json
    error = assert_raises(ClientError) {
      WellFormedArgs.new(json).manifest
    }
    assert_equal 'malformed:manifest:unknown key[x]', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '592',
  'manifest raises when malformed' do
    malformed_manifests.each do |malformed|
      json = { manifest:malformed }.to_json
      error = assert_raises {
        WellFormedArgs.new(json).manifest
      }
      assert_equal 'malformed:manifest:', error.message, malformed
    end
  end

  def malformed_manifests
    bad_month = [2018,-3,28, 11,33,13]
    bad_year = ["2018",3,28, 11,33,13]
    [
      [],                                                 # ! Hash
      starter.manifest.merge({visible_files:[]}),            # ! Hash
      starter.manifest.merge({visible_files:{'s' => [4]}}),  # ! Hash{s->s}
      starter.manifest.merge({display_name:42}),          # ! String
      starter.manifest.merge({image_name:42}),            # ! String
      starter.manifest.merge({runner_choice:42}),         # ! String
      starter.manifest.merge({filename_extension:true}),  # ! String && ! Array
      starter.manifest.merge({filename_extension:{}}),    # ! String && ! Array
      starter.manifest.merge({filename_extension:[23]}),  # ! Array[String]
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
      starter.manifest.merge({id:true}),             # ! string
      starter.manifest.merge({id:'df/sdf/sdf'}),     # ! IdGenerator.string
      starter.manifest.merge({id:'12345'}),          # ! 6-chars long
    ]
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
    expected = 'malformed:id:'
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
      '12345/'      # ! IdGenerator chars
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
    expected = 'malformed:indexes:'
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

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # index
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '237',
  'index does not raise when well-formed' do
    oks = [ -1, 0, 104 ]
    oks.each do |index|
      json = { index:index }.to_json
      assert_equal index, WellFormedArgs.new(json).index
    end
  end

  test '238',
  'index raises when malformed' do
    expected = 'malformed:index:'
    malformeds = [ nil, true, [1], {}, '', '23', -2 ]
    malformeds.each do |malformed|
      json = { index:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      diagnostic = ":#{malformed.to_s}:"
      error = assert_raises(diagnostic) { wfa.index }
      assert_equal expected, error.message, diagnostic
    end
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
    expected = 'malformed:files:'
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
  # now
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF4',
  'now does not raise when well-formed' do
    now = [2018,3,28, 19,18,45]
    json = { now:now }.to_json
    assert_equal now, WellFormedArgs.new(json).now
  end

  test 'FF5',
  'now raises when malformed' do
    expected = 'malformed:now:'
    malformed_nows.each do |malformed|
      json = { now:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.now }
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_nows
    [
      [], {}, nil, true, 42,    # ! Arrays
      ["2018",3,28, 19,18,45],  # ! Array[String]
      [2018,3,28, 19,18],       # ! Array.length == 6
      [2018,-3,28,  19,18,45]   # ! Time
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # stdout
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E35',
  'stdout does not raise when well-formed' do
    stdout = 'gsdfg'
    json = { stdout:stdout }.to_json
    assert_equal stdout, WellFormedArgs.new(json).stdout
  end

  test 'E36',
  'stdout raises when malformed' do
    expected = 'malformed:stdout:'
    malformed_stdouts.each do |malformed|
      json = { stdout:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.stdout }
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_stdouts
    [ nil, true, [1], {} ] # ! String
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # stderr
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8DB',
  'stderr does not raise when well-formed' do
    stderr = 'ponoi'
    json = { stderr:stderr }.to_json
    assert_equal stderr, WellFormedArgs.new(json).stderr
  end

  test '8DC',
  'stderr raises when malformed' do
    expected = 'malformed:stderr:'
    malformed_stderrs.each do |malformed|
      json = { stderr:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.stderr }
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_stderrs
    [ nil, true, [1], {} ] # ! String
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # status
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CD3',
  'status does not raise when well-formed' do
    oks = [ 0, 24, 255 ]
    oks.each do |status|
      json = { status:status }.to_json
      assert_equal status, WellFormedArgs.new(json).status
    end
  end

  test 'CD4',
  'status raises when malformed' do
    expected = 'malformed:status:'
    malformeds = [ nil, true, [1], {}, '', '23', -1, 256 ]
    malformeds.each do |malformed|
      json = { status:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      diagnostic = ":#{malformed.to_s}:"
      error = assert_raises(diagnostic) { wfa.status }
      assert_equal expected, error.message, diagnostic
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '041',
  'colour does not raise when well-formed' do
    colours = [ 'red', 'amber', 'green', 'timed_out' ]
    colours.each do |colour|
      json = { colour:colour }.to_json
      assert_equal colour, WellFormedArgs.new(json).colour
    end
  end

  test '042',
  'colour raises when malformed' do
    expected = 'malformed:colour:'
    malformed_colours.each do |malformed|
      json = { colour:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.colour }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_colours
    [ nil, true, {}, [], 'RED' ]
  end

end
