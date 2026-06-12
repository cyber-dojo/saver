require_relative 'lib/json_adapter'
require_relative 'model/id_pather'
require_relative 'model/group_v0'
require_relative 'model/group_v1'
require_relative 'model/group_v2'
require_relative 'model/kata_v0'
require_relative 'model/kata_v1'
require_relative 'model/kata_v2'
require_relative 'model/cluster'

class Model

  def initialize(externals)
    @externals = externals
  end

  def group_create(manifest:)
    version = from_manifest(manifest)
    GROUPS[version].new(@externals).create(manifest)
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

  def cluster_create(manifest:)
    Cluster.new(@externals).create(manifest)
  end

  def cluster_manifest(id:)
    Cluster.new(@externals).manifest(id)
  end

  # True if a cluster with this id exists.
  def cluster_exists?(id:)
    unless id?(id)
      return false
    end
    disk.run(disk.dir_exists_command(cluster_id_path(id)))
  end

  # The id-chain from the given entity up to the topmost one, ordered
  # bottom-to-top as [{type,id}, ...]; eg a kata in a cluster returns
  # [{kata},{group},{cluster}]. The top id is the last entry's id. Each step
  # appends its entry and advances id to its parent (group_id, then cluster_id).
  def id_hierarchy(id:)
    result = []
    if kata_exists?(id:id)
      result << { 'type' => 'kata', 'id' => id }
      id = kata_manifest(id:id)['group_id']
    end
    if group_exists?(id:id)
      result << { 'type' => 'group', 'id' => id }
      id = group_manifest(id:id)['cluster_id']
    end
    if cluster_exists?(id:id)
      result << { 'type' => 'cluster', 'id' => id }
    end
    result
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

  def group_fork(id:, index:)
    kata(id).fork(Group_v2, id, index)
  end

  def kata_create(manifest:)
    version = from_manifest(manifest)
    KATAS[version].new(@externals).create(manifest)
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

  # - - - - - - - - - - - - - - - - - - - -

  def kata_file_create(id:, index:, files:, filename:)
    kata(id).file_create(id, index, files, filename)
  end

  def kata_file_delete(id:, index:, files:, filename:)
    kata(id).file_delete(id, index, files, filename)
  end

  def kata_file_rename(id:, index:, files:, old_filename:, new_filename:)
    kata(id).file_rename(id, index, files, old_filename, new_filename)
  end

  def kata_file_edit(id:, index:, files:)
    kata(id).file_edit(id, index, files)
  end

  # - - - - - - - - - - - - - - - - - - - -

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

  # - - - - - - - - - - - - - - - - - - - -

  def kata_download(id:)
    kata(id).download(id)
  end

  def kata_fork(id:, index:)
    kata(id).fork(Kata_v2, id, index)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def kata_option_get(id:, name:)
    kata(id).option_get(id, name)
  end

  def kata_option_set(id:, name:, value:)
    kata(id).option_set(id, name, value)
  end

  def diff_lines(id:, was_index:, now_index:)
    kata(id).diff_lines(id, was_index, now_index)
  end

  def diff_summary(id:, was_index:, now_index:)
    kata(id).diff_summary(id, was_index, now_index)
  end

  CURRENT_VERSION = 2

  private

  AVATAR_INDEXES = (0..63).to_a

  include IdPather
  include JsonAdapter

  def group(id)
    GROUPS[from_path(group_id_path(id, 'manifest.json'))].new(@externals)
  end

  def kata(id)
    KATAS[kata_version(id)].new(@externals)
  end

  def from_path(path)
    content = disk.assert(disk.file_read_command(path))
    manifest = json_parse(content)
    manifest['version'].to_i # nil.to_i == 0
  end

  # A v2 kata is a git repo; v0/v1 are flat files. A .git stat is cheaper than
  # from_path's manifest read+parse, on a path hit by every kata operation.
  # Only v2 uses git, so .git present => v2; otherwise fall back to the legacy
  # manifest read, which must report v0 or v1 (a v2 without .git is an anomaly).
  def kata_version(id)
    if disk.run(disk.dir_exists_command(kata_id_path(id, '.git')))
      2
    else
      version = from_path(kata_id_path(id, 'manifest.json'))
      unless [0, 1].include?(version)
        fail "kata #{id} has no .git but manifest version is #{version}"
      end
      version
    end
  end

  def from_manifest(manifest)
    # All newly created groups and katas use the current version.
    # Allow creation from previous versions for tests.
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
