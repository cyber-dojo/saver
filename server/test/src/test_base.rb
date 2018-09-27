require_relative 'hex_mini_test'
require_relative 'external_starter'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def sha
    grouper.sha
  end

  # - - - - - - - - - - - - - - - - -

  def create(manifest)
    grouper.create(manifest)
  end

  def manifest(id)
    grouper.manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def id?(id)
    grouper.id?(id)
  end

  # - - - - - - - - - - - - - - - - -

  def id_completed(partial_id)
    grouper.id_completed(partial_id)
  end

  def id_completions(outer_id)
    grouper.id_completions(outer_id)
  end

  # - - - - - - - - - - - - - - - - -

  def join(id)
    grouper.join(id)
  end

  def joined(id)
    grouper.joined(id)
  end

  # - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - -

  def create_manifest
    starter = ExternalStarter.new
    manifest = starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
    manifest['created'] = creation_time
    manifest
  end

  def creation_time
    [2016,12,2, 6,13,23]
  end

  def externals
    @externals ||= Externals.new
  end

  def stub_create(stub_id)
    stub_id_generator.stub(stub_id)
    id = create(create_manifest)
    assert_equal stub_id, id
    id
  end

  private

  def grouper
    externals.grouper
  end

end