require_relative 'test_base'

class KataCreateTest < TestBase

  def self.id58_prefix
    'e09'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'h35', %w(
  |POST /kata_create(manifest)
  |has status 200
  |returns the id: of a new kata
  |that exists in saver
  ) do
    assert_json_post_200(
      path = 'kata_create',
      { manifest:custom_manifest }.to_json
    ) do |response|
      assert_equal [path], response.keys, :keys
      id = response[path]
      assert kata_exists?(id), :exists
      assert_equal version, kata_manifest(id)['version'], :version
    end
  end

end
