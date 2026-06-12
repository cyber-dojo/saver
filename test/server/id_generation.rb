require_relative 'test_base'
require_source 'model/id_generator'
require 'fileutils'
require 'tmpdir'

class IdGenerationTest < TestBase

  test 'A6D062', %w(
  | alphabet has 58 characters
  ) do
    assert_equal 58, alphabet.size
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D065', %w(
  | every letter of the alphabet can be used as part of a dir-name
  ) do
    diagnostic = 'forward slash is the dir separator'
    refute alphabet.include?('/'), diagnostic
    diagnostic = 'dot is a dir navigator'
    refute alphabet.include?('.'), diagnostic
    diagnostic = 'single quote to protect all other letters'
    refute alphabet.include?("'"), diagnostic
    alphabet.each_char do |letter|
      path = Dir.mktmpdir("/tmp/#{letter}")
      FileUtils.mkdir_p(path)
      at_exit { FileUtils.remove_entry(path) }
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D13d', %w(
  | id 999999 is reserved for a kata id when saver is offline
  ) do
    id = 'eF762A'
    id_generator = stubbed_id_generator(saver_offline_id+id)
    assert_equal id, id_generator.kata_id
  end

  # - - - - - - - - - - - - - - - - - - -

  version_test 2, 'A6D14a', %w(
  | kata-id generator will skip id that already exists as a group
  ) do
    in_group do |group_id|
      id = "x67Wp#{version}"
      id_generator = stubbed_id_generator(group_id + id)
      assert_equal id, id_generator.kata_id
    end
  end

  version_test 2, 'A6D14f', %w(
  | kata-id generator retries when dir creation fails
  | because the kata directory already exists
  | (id is absent as a group but present as a kata - the rescue-next path)
  ) do
    in_kata do |kata_id|
      id = 'zP3q8V'
      id_generator = stubbed_id_generator(kata_id + id)
      assert_equal id, id_generator.kata_id
    end
  end

  versions_01_test 'A6D14c', %w(
  | kata-id generator will skip id that already exists as a pre-existing v0/v1 group
  ) do
    gids = { 0 => 'FxWwrr', 1 => 'REf1t8' }
    group_id = gids[version]
    id = "x67Wp#{version}"
    id_generator = stubbed_id_generator(group_id + id)
    assert_equal id, id_generator.kata_id
  end

  # - - - - - - - - - - - - - - - - - - -

  version_test 2, 'A6D14b', %w(
  | group-id generator will skip id that already exists as a kata
  ) do
    in_kata do |kata_id|
      id = "hY86s#{version}"
      id_generator = stubbed_id_generator(kata_id + id)
      assert_equal id, id_generator.group_id
    end
  end

  versions_01_test 'A6D14d', %w(
  | group-id generator will skip id that already exists as a pre-existing v0/v1 kata
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    kata_id = kids[version]
    id = "hY86s#{version}"
    id_generator = stubbed_id_generator(kata_id + id)
    assert_equal id, id_generator.group_id
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D14g', %w(
  | kata-id generator will skip an id that already exists as a cluster
  ) do
    cluster_id = cluster_create(
      'exercise' => 'Tennis',
      'ltfs' => [
        manifest_Tennis_refactoring_Python_unitttest,
        manifest_Tennis_refactoring_Ruby_minitest
      ]
    )
    id = 'kP4mR9'
    id_generator = stubbed_id_generator(cluster_id + id)
    assert_equal id, id_generator.kata_id
  end

  test 'A6D14h', %w(
  | group-id generator will skip an id that already exists as a cluster
  ) do
    cluster_id = cluster_create(
      'exercise' => 'Tennis',
      'ltfs' => [
        manifest_Tennis_refactoring_Python_unitttest,
        manifest_Tennis_refactoring_Ruby_minitest
      ]
    )
    id = 'gT7wQ2'
    id_generator = stubbed_id_generator(cluster_id + id)
    assert_equal id, id_generator.group_id
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D068', %w(
  | id?(s) true examples
  ) do
    assert id?('012AaE')
    assert id?('345BbC')
    assert id?('678HhJ')
    assert id?('999PpQ')
    assert id?('263VvW')
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D069', %w(
  | id?(s) false examples
  ) do
    refute id?(42),  :integer_not_string
    refute id?(nil), :nil_not_string
    refute id?({}),  :hash_not_string
    refute id?([]),  :array_not_string
    refute id?('I'), :India_not_in_alphabet
    refute id?('i'), :india_not_in_alphabet
    refute id?('O'), :Oscar_not_in_alphabet
    refute id?('o'), :oscar_not_in_alphabet
    refute id?('12345'), :not_length_6
    refute id?('1234567'), :not_length_6
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D13e', %w(
  | kata-id generation tries 256 times and then gives up and returns nil
  ) do
    id_generator = stubbed_id_generator(saver_offline_id*256)
    assert_nil id_generator.kata_id
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D13f', %w(
  | group-id generation tries 256 times and then gives up and returns nil
  ) do
    id_generator = stubbed_id_generator(saver_offline_id*256)
    assert_nil id_generator.group_id
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D13b', %w(
  | group-id does not exist before generation but does after
  ) do
    id =  'sD92wM'
    refute group_exists?(id), "group_exists?(#{id}) !!"
    id_generator = stubbed_id_generator(id)
    assert_equal id, id_generator.group_id
    assert group_exists?(id), "!group_exists?(#{id}) !!"
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A6D13c', %w(
  | kata-id does not exist before generation but does after
  ) do
    id =  '7w3RPx'
    refute kata_exists?(id), "kata_exists?(#{id}) !!"
    id_generator = stubbed_id_generator(id)
    assert_equal id, id_generator.kata_id
    assert kata_exists?(id), "!kata_exists?(#{id}) !!"
  end

  private

  include IdPather

  def id?(s)
    IdGenerator::id?(s)
  end

  def alphabet
    IdGenerator::ALPHABET
  end

  def saver_offline_id
    IdGenerator::SAVER_OFFLINE_ID
  end

  def stubbed_id_generator(stub)
    externals.instance_exec {
      @random = RandomStub.new(stub)
    }
    IdGenerator.new(externals)
  end

end
