require_relative 'hex_mini_test'
require_relative 'external_starter'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def sha
    grouper.sha
  end

  # - - - - - - - - - - - - - - - - -

  def group_create(manifest)
    grouper.group_create(manifest)
  end

  def group_manifest(id)
    grouper.group_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def group_exists?(id)
    grouper.group_exists?(id)
  end

  # - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    grouper.group_join(id, indexes)
  end

  def group_joined(id)
    grouper.group_joined(id)
  end

  # - - - - - - - - - - - - - - - - -

  def stub_group_create(stub_id)
    manifest = starter.manifest
    manifest['id'] = stub_id
    id = group_create(manifest)
    assert_equal stub_id, id
    id
  end

  # - - - - - - - - - - - - - - - - -

  def starter
    ExternalStarter.new
  end

  def externals
    @externals ||= Externals.new
  end

  private

  def grouper
    externals.grouper
  end

end