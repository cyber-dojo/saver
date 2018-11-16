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
      smm({filename_extension:'.h'}),
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '592',
  'manifest raises when malformed' do
    malformed_manifests.each do |malformed, message|
      json = { manifest:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.manifest }
      expected = "malformed:#{message}:"
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_manifests
    string_year = ["2018",3,28, 11,33,13,67]
    negative_month = [2018,-3,28, 11,33,13,789]
    {
      [] => 'manifest:!Hash',

      smd('display_name') => 'manifest["display_name"]:missing',

      smm({x:false}) => 'manifest["x"]:unknown',

      smm({id:23})           => 'manifest["id"]:!Base58',
      smm({id:'df/sdf/sdf'}) => 'manifest["id"]:!Base58',
      smm({id:true})         => 'manifest["id"]:!Base58',
      smm({id:'12345'})      => 'manifest["id"]:size==5 -> !6',

      smm({created:nil})       => 'manifest["created"]:!Array',
      smm({created:[]})        => 'manifest["created"]:size==0 -> !7',
      smm({created:string_year})  => 'manifest["created"]:[0] -> !Integer',
      smm({created:negative_month}) => 'manifest["created"]:argument out of range',

      smm({display_name:42})   => 'manifest["display_name"]:!String',
      smm({image_name:{}})     => 'manifest["image_name"]:!String',
      smm({runner_choice:nil}) => 'manifest["runner_choice"]:!String',
      smm({exercise:true})     => 'manifest["exercise"]:!String',

      smm({visible_files:[]}) => 'manifest["visible_files"]:!Hash',
      smm({visible_files:{'s' => [4]}}) => 'manifest["visible_files"]:["s"] -> !String',

      smm({filename_extension:true}) => 'manifest["filename_extension"]:!Array',
      smm({filename_extension:{}}) => 'manifest["filename_extension"]:!Array',
      smm({filename_extension:[23]}) => 'manifest["filename_extension"]:[0] -> !String',
      smm({filename_extension:['.rb',23]}) => 'manifest["filename_extension"]:[1] -> !String',

      smm({highlight_filenames:1}) => 'manifest["highlight_filenames"]:!Array',
      smm({highlight_filenames:[1]}) => 'manifest["highlight_filenames"]:[0] -> !String',
      smm({highlight_filenames:['.txt',1]}) => 'manifest["highlight_filenames"]:[1] -> !String',

      smm({progress_regexs:{}}) => 'manifest["progress_regexs"]:!Array',
      smm({progress_regexs:[1]}) => 'manifest["progress_regexs"]:[0] -> !String',
      smm({progress_regexs:['xxx',1]}) => 'manifest["progress_regexs"]:[1] -> !String',

      smm({tab_size:true}) => 'manifest["tab_size"]:!Integer',
      smm({tab_size:0}) => 'manifest["tab_size"]:!(1..8)',
      smm({tab_size:9}) => 'manifest["tab_size"]:!(1..8)',

      smm({max_seconds:nil}) => 'manifest["max_seconds"]:!Integer',
      smm({max_seconds:0}) => 'manifest["max_seconds"]:!(1..20)',
      smm({max_seconds:21}) => 'manifest["max_seconds"]:!(1..20)',
    }
  end

  def smm(h)
    starter.manifest.merge(h)
  end

  def smd(k)
    m = starter.manifest
    m.delete(k)
    m
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
    malformed_ids.each do |malformed,message|
      json = { id:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.id }
      expected = "malformed:id:#{message}:"
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_ids
    {
      nil      => '!Base58',
      []       => '!Base58',
      '12345/' => '!Base58',
      ''        => 'size==0 -> !6',
      '12'      => 'size==2 -> !6',
      '12345'   => 'size==5 -> !6',
      '1234567' => 'size==7 -> !6',
    }
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
    malformed_indexes.each do |malformed, message|
      json = { indexes:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.indexes }
      expected = "malformed:indexes:#{message}:"
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_indexes
    {
      42 => '!Array',
      "string" => '!Array',
      false => '!Array',
      {} => '!Array',
      [] => 'size==0 -> !64',
      [0,1] => 'size==2 -> !64',
      [62,63] => 'size==2 -> !64',
      (1..64).to_a => '!(0..63)',
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # index
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '237',
  'index does not raise when well-formed' do
    well_formed_indexes = [ -1, 0, 1, 2, 55, 104 ]
    well_formed_indexes.each do |index|
      json = { index:index }.to_json
      assert_equal index, WellFormedArgs.new(json).index
    end
  end

  test '238',
  'index raises when malformed' do
    malformed_index.each do |malformed,message|
      json = { index:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.index }
      expected = "malformed:index:#{message}:"
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_index
    {
      nil => '!Integer',
      true => '!Integer',
      [1] => '!Integer',
      {} => '!Integer',
      '' => '!Integer',
      '23' => '!Integer',
      -2 => 'argument out of range',
    }
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
    malformed_files.each do |malformed, message|
      json = { files:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.files }
      expected = "malformed:files:#{message}:"
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_files
    {
      [] => '!Hash',
      { "x" => 42   } => '["x"] -> !String',
      { "y" => true } => '["y"] -> !String',
      { "z" => nil  } => '["z"] -> !String',
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # now
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF4',
  'now does not raise when well-formed' do
    now = [2018,3,28, 19,18,45,356]
    json = { now:now }.to_json
    assert_equal now, WellFormedArgs.new(json).now
  end

  test 'FF5',
  'now raises when malformed' do
    malformed_nows.each do |malformed, message|
      json = { now:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.now }
      expected = "malformed:now:#{message}:"
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_nows
    {
      {} => '!Array',
      nil => '!Array',
      true => '!Array',
      42 => '!Array',
      [] => 'size==0 -> !7',
      [2018,3,28, 19,18,1] => 'size==6 -> !7',
      [2018,3,28, 19,18,1,0,0] => 'size==8 -> !7',
      [2018,-3,28, 19,18,45,934] => 'argument out of range',
      [2018,30,11, 19,18,45,934] => 'argument out of range',
      ["2018",3,28, 19,18,45,934] => '[0] -> !Integer',
      [2018,{},28, 19,18,45,934] => '[1] -> !Integer',
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # duration
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9E0',
  'duration does not raise when well-formed' do
    duration = 0.0
    json = { duration:duration }.to_json
    assert_equal duration, WellFormedArgs.new(json).duration
    duration = 0.34
    json = { duration:duration }.to_json
    assert_equal duration, WellFormedArgs.new(json).duration
  end

  test '9E1',
  'duration raises when malformed' do
    malformed_durations.each do |malformed, message|
      json = { duration:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.duration }
      expected = "malformed:duration:#{message}:"
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_durations
    {
      {} => '!Float',
      nil => '!Float',
      true => '!Float',
      42 => '!Float',
      -0.4 => '!(>= 0.0)'
    }
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
    malformed_stdouts.each do |malformed|
      json = { stdout:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.stdout }
      expected = 'malformed:stdout:!String:'
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_stdouts
    [ nil, true, [1], {} ]
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
    malformed_stderrs.each do |malformed|
      json = { stderr:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.stderr }
      expected = 'malformed:stderr:!String:'
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_stderrs
    [ nil, true, [1], {} ]
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
    malformed_statuses.each do |malformed,message|
      json = { status:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.status }
      expected = "malformed:status:#{message}:"
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_statuses
    {
      nil => '!Integer',
      true => '!Integer',
      [1] => '!Integer',
      {} => '!Integer',
      '' => '!Integer',
      '23' => '!Integer',
      -1 => '!(0..255)',
      256 => '!(0..255)'
    }
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
    malformed_colours.each do |malformed,message|
      json = { colour:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises(ClientError) { wfa.colour }
      expected = "malformed:colour:#{message}:"
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_colours
    {
      nil => '!String',
      true => '!String',
      {} => '!String',
      [] => '!String',
      'RED' => "!['red'|'amber'|'green'|'timed_out']"
    }
  end

end