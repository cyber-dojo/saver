require_relative 'lib/json_adapter'
require_relative 'model/id_pather'
require_relative 'model/group_v0'
require_relative 'model/group_v1'
require_relative 'model/group_v2'
require_relative 'model/kata_v0'
require_relative 'model/kata_v1'
require_relative 'model/kata_v2'

class Model

  def initialize(externals)
    @externals = externals
  end

  #- - - - - - - - - - - - - - - - - -

  def group_create(manifests:, options:)
    manifest = manifests[0]
    version = from_manifest(manifest)
    group(version).create(manifest, options)
  end

  def group_exists?(id:)
    unless id?(id)
      return false
    end
    dir_name = group_id_path(id)
    disk.run(disk.dir_exists_command(dir_name))
  end

  def group_manifest(id:)
    group(id).manifest(id)
  end

  def group_join(id:, indexes:AVATAR_INDEXES.shuffle)
    group(id).join(id, indexes)
  end

  def group_joined(id:)
    if kata_exists?(id:id)
      manifest = kata_manifest(id:id)
      group_id = manifest["group_id"]
      if group_id.nil?
        return {}
      else
        id = group_id
      end
    end
    group(id).joined(id)
  end

  #- - - - - - - - - - - - - - - - - -

  def kata_create(manifest:, options:)
    version = from_manifest(manifest)
    kata(version).create(manifest, options)
  end

  def kata_exists?(id:)
    unless id?(id)
      return false
    end
    dir_name = kata_id_path(id)
    disk.run(disk.dir_exists_command(dir_name))
  end

  def kata_manifest(id:)
    kata(id).manifest(id)
  end

  def kata_events(id:)
    kata(id).events(id)
  end

  def kata_event(id:, index:)
    kata(id).event(id, index)
  end

  def katas_events(ids:, indexes:)
    id = ids[0]
    kata(id).event_batch(ids, indexes)
  end

  def kata_ran_tests(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(id).ran_tests(id, index, files, stdout, stderr, status, summary)
  end

  def kata_predicted_right(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(id).predicted_right(id, index, files, stdout, stderr, status, summary)
  end

  def kata_predicted_wrong(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(id).predicted_wrong(id, index, files, stdout, stderr, status, summary)
  end

  def kata_reverted(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(id).reverted(id, index, files, stdout, stderr, status, summary)
  end

  def kata_checked_out(id:, index:, files:, stdout:, stderr:, status:, summary:)
    kata(id).checked_out(id, index, files, stdout, stderr, status, summary)
  end

  def kata_option_get(id:, name:)
    kata(CURRENT_VERSION).option_get(id, name)
  end

  def kata_option_set(id:, name:, value:)
    kata(CURRENT_VERSION).option_set(id, name, value)
  end

  CURRENT_VERSION = 1

  private

  AVATAR_INDEXES = (0..63).to_a

  include IdPather
  include JsonAdapter

  def group(id)
    if id?(id)
      version = from_path(group_id_path(id, 'manifest.json'))
    else
      version = id
    end
    GROUPS[version].new(@externals)
  end

  def kata(id)
    if id?(id)
      version = from_path(kata_id_path(id, 'manifest.json'))
    else
      version = id
    end
    KATAS[version].new(@externals)
  end

  def from_path(path)
    content = disk.assert(disk.file_read_command(path))
    manifest = json_parse(content)
    manifest['version'].to_i # nil.to_i == 0
  end

  def from_manifest(manifest)
    (manifest['version'] || CURRENT_VERSION).to_i
  end

  def id?(id)
    IdGenerator::id?(id)
  end

  def disk
    @externals.disk
  end

  GROUPS = [ Group_v0, Group_v1, Group_v2 ]
  KATAS = [ Kata_v0, Kata_v1, Kata_v2 ]

end
