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

  # The id-chain from the given entity up to the topmost one, ordered
  # bottom-to-top as [{type,id}, ...]; eg a kata in a cluster returns
  # [{kata},{group},{cluster}]. The top id is the last entry's id. Each step
  # appends its entry and advances id to its parent (group_id, then cluster_id).
  def id_chain(id:)
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
    # An empty result means the original id matched no kata, group or cluster
    # (id is only reassigned inside a block that also appends an entry). That is
    # a client error (400), not an empty hierarchy.
    if result.empty?
      fail RequestError, "id #{id} does not exist"
    end
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def cluster_create(manifests:)
    Cluster.new(@externals).create(manifests)
  end

  def cluster_manifest(id:)
    Cluster.new(@externals).manifest(id)
  rescue StandardError => error
    # Classify a failed cluster resolution: a well-formed but non-existent
    # cluster-id is a client error (400), not the generic server error (500)
    # raised by Cluster#manifest's disk.assert read. Real failures on a cluster
    # that does exist are re-raised unchanged.
    raise error if cluster_exists?(id:id)
    fail RequestError, "cluster #{id} does not exist"
  end

  # True if a cluster with this id exists.
  def cluster_exists?(id:)
    unless id?(id)
      return false
    end
    disk.run(disk.dir_exists_command(cluster_id_path(id)))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  # - - - - - - - - - - - - - - - - - - - -

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

  # index and laptop_id are optional keywords so the strict-keyword dispatch does
  # not 500 when a caller omits them:
  # - index: the saver assigns each event's position (head + 1), so it does not
  #   need a client index and ignores any it is sent. A caller can stop sending it.
  # - laptop_id: the id of the browser (laptop) that made the write. The saver
  #   stamps it on the committed event; the browser's read-side poll uses it to
  #   tell one laptop's events from another's (mobbing detection).

  def kata_file_create(id:, index: nil, files:, filename:, laptop_id: nil)
    kata(id).file_create(id, files, filename, laptop_id)
  end

  def kata_file_delete(id:, index: nil, files:, filename:, laptop_id: nil)
    kata(id).file_delete(id, files, filename, laptop_id)
  end

  def kata_file_rename(id:, index: nil, files:, old_filename:, new_filename:, laptop_id: nil)
    kata(id).file_rename(id, files, old_filename, new_filename, laptop_id)
  end

  def kata_file_edit(id:, index: nil, files:, laptop_id: nil)
    kata(id).file_edit(id, files, laptop_id)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id:, index: nil, files:, stdout:, stderr:, status:, summary:, laptop_id: nil)
    kata(id).ran_tests(id, files, stdout, stderr, status, summary, laptop_id)
  end

  def kata_predicted_right(id:, index: nil, files:, stdout:, stderr:, status:, summary:, laptop_id: nil)
    kata(id).predicted_right(id, files, stdout, stderr, status, summary, laptop_id)
  end

  def kata_predicted_wrong(id:, index: nil, files:, stdout:, stderr:, status:, summary:, laptop_id: nil)
    kata(id).predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id)
  end

  def kata_reverted(id:, index: nil, files:, stdout:, stderr:, status:, summary:, laptop_id: nil)
    kata(id).reverted(id, files, stdout, stderr, status, summary, laptop_id)
  end

  def kata_checked_out(id:, index: nil, files:, stdout:, stderr:, status:, summary:, laptop_id: nil)
    kata(id).checked_out(id, files, stdout, stderr, status, summary, laptop_id)
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

  # - - - - - - - - - - - - - - - - - - - -

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
  rescue StandardError => error
    # Classify a failed group resolution: a well-formed but non-existent
    # gid is a client error (400), not the generic server error (500) raised
    # by from_path's manifest read. Real failures on a group that does exist
    # are re-raised unchanged.
    raise error if group_exists?(id:id)
    fail RequestError, "group #{id} does not exist"
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
  rescue StandardError => error
    # Classify a failed version-detection: a well-formed but non-existent
    # kata-id is a client error (400), not the generic server error (500)
    # raised by from_path's manifest read. Real failures on a kata that does
    # exist are re-raised unchanged.
    raise error if kata_exists?(id:id)
    fail RequestError, "kata #{id} does not exist"
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
