# frozen_string_literal: true
require_relative 'lib/json_adapter'
require_relative 'model/id_pather'
require_relative 'model/group_v0'
require_relative 'model/group_v1'
require_relative 'model/kata_v0'
require_relative 'model/kata_v1'

class Model

  def initialize(externals)
    @externals = externals
  end

  #- - - - - - - - - - - - - - - - - -

  def group_create(manifests:, options:)
    manifest = manifests[0]
    version = (manifest['version'] || CURRENT_VERSION).to_i
    group(version).create(manifest, options)
  end

  def group_exists?(id:)
    group(CURRENT_VERSION).exists?(id)
  end

  def group_manifest(id:)
    group(version_group(id)).manifest(id)
  end

  def group_join(id:, indexes:AVATAR_INDEXES.shuffle)
    group(version_group(id)).join(id, indexes)
  end

  def group_joined(id:)
    if kata_exists?(id:id)
      manifest = json_parse(kata_manifest(id:id))
      group_id = manifest["group_id"]
      if group_id.nil?
        return '{}'
      else
        id = group_id
      end
    end
    group(version_group(id)).joined(id)
  end

  #- - - - - - - - - - - - - - - - - -

  def kata_create(manifest:, options:)
    version = (manifest['version'] || CURRENT_VERSION).to_i
    kata(version).create(manifest, options)
  end

  def kata_exists?(id:)
    kata(CURRENT_VERSION).exists?(id)
  end

  def kata_manifest(id:)
    kata(version_kata(id)).manifest(id)
  end

  def kata_events(id:)
    kata(version_kata(id)).events(id)
  end

  def kata_event(id:, index:)
    kata(version_kata(id)).event(id, index)
  end

  def katas_events(ids:, indexes:)
    id = ids[0]
    kata(version_kata(id)).event_batch(ids, indexes)
  end

  def kata_ran_tests(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(version_kata(id)).ran_tests(id, index, files, stdout, stderr, status, summary)
  end

  def kata_predicted_right(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(version_kata(id)).predicted_right(id, index, files, stdout, stderr, status, summary)
  end

  def kata_predicted_wrong(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(version_kata(id)).predicted_wrong(id, index, files, stdout, stderr, status, summary)
  end

  def kata_reverted(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(version_kata(id)).reverted(id, index, files, stdout, stderr, status, summary)
  end

  def kata_checked_out(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(version_kata(id)).checked_out(id, index, files, stdout, stderr, status, summary)
  end

  def kata_option_get(id:, name:)
    kata(1).option_get(id, name)
  end

  def kata_option_set(id:, name:, value:)
    kata(1).option_set(id, name, value)
  end

  private

  AVATAR_INDEXES = (0..63).to_a

  include IdPather
  include JsonAdapter

  def group(version)
    GROUPS[version].new(@externals)
  end

  def kata(version)
    KATAS[version].new(@externals)
  end

  def version_group(id)
    version_path(group_id_path(id, 'manifest.json'))
  end

  def version_kata(id)
    version_path(kata_id_path(id, 'manifest.json'))
  end

  def version_path(path)
    manifest_src = saver.assert(saver.file_read_command(path))
    manifest = json_parse(manifest_src)
    # if manifest['version'].nil?
    # then nil.to_i ==> 0 which is what we want
    manifest['version'].to_i
  end

  def saver
    @externals.saver
  end

  CURRENT_VERSION = 1
  GROUPS = [ Group_v0, Group_v1 ]
  KATAS = [ Kata_v0, Kata_v1 ]

end
