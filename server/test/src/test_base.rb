require_relative 'hex_mini_test'
require_relative 'external_starter'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def sha
    grouper.sha
  end

  # - - - - - - - - - - - - - - - - -

  def group_exists?(id)
    grouper.group_exists?(id)
  end

  def group_create(manifest)
    grouper.group_create(manifest)
  end

  def group_manifest(id)
    grouper.group_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    grouper.group_join(id, indexes)
  end

  def group_joined(id)
    grouper.group_joined(id)
  end

  # - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    singler.kata_exists?(id)
  end

  def kata_create(manifest)
    singler.kata_create(manifest)
  end

  def kata_manifest(id)
    singler.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
    singler.kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
  end

  def kata_tags(id)
    singler.kata_tags(id)
  end

  def kata_tag(id, n)
    singler.kata_tag(id, n)
  end

  #- - - - - - - - - - - - - - -

  def stub_group_create(stub_id)
    manifest = starter.manifest
    manifest['id'] = stub_id
    id = group_create(manifest)
    assert_equal stub_id, id
    id
  end

  def stub_kata_create(stub_id)
    manifest = starter.manifest
    manifest['id'] = stub_id
    id = kata_create(manifest)
    assert_equal stub_id, id
    id
  end

  #- - - - - - - - - - - - - - -

  def starter
    ExternalStarter.new
  end

  def externals
    @externals ||= Externals.new
  end

  def creation_time
    starter.creation_time
  end

  private

  def grouper
    externals.grouper
  end

  def singler
    externals.singler
  end

end