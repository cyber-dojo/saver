require_relative 'lib/json_adapter'
require_relative 'model/event_index'
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
    id = kata_link(result, id)
    id = group_link(result, id)
    cluster_link(result, id)
    existing_chain(result, id)
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

  # Joins a new avatar to the group of kata id, starting from the files of
  # its traffic-light at index, and gives it that light, checked out from
  # kata id, so it opens with a light. Returns the new avatar's kata id, or
  # nil when full. Only a traffic-light that is a test result can be forked;
  # the creation event, file events, and pulling, timed_out and faulty lights
  # are request errors.
  def avatar_fork(id:, index:, indexes:AVATAR_INDEXES.shuffle)
    manifest = kata_manifest(id:id)
    group_id = fork_group_id(id, manifest)
    light = fork_light(id, index)
    event = kata_event(id:id, index:index)
    avatar_id = group(group_id).join(group_id, indexes, event['files'])
    checkout = fork_checkout(id, index, light, manifest)
    check_out_avatar(avatar_id, event, light, checkout)
    avatar_id
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

  # The saver assigns each event's position (head + 1), so a write states what
  # happened and the saver decides where it lands.
  #
  # laptop_id is the id of the browser (laptop) that made the write. The saver
  # stamps a well-formed one on the committed event; the browser's read-side poll
  # uses it to tell one laptop's events from another's (mobbing detection).
  #
  # tab_seq is the tab's own monotonic event counter, forming the idempotency key
  # (laptop_id, tab_seq). A write whose key is already committed is a no-op, so a
  # redelivered write is not committed twice.

  def kata_file_create(id:, files:, filename:, laptop_id:, tab_seq:)
    kata(id).file_create(id, files, filename, laptop_id, tab_seq)
  end

  def kata_file_delete(id:, files:, filename:, laptop_id:, tab_seq:)
    kata(id).file_delete(id, files, filename, laptop_id, tab_seq)
  end

  def kata_file_rename(id:, files:, old_filename:, new_filename:, laptop_id:, tab_seq:)
    kata(id).file_rename(id, files, old_filename, new_filename, laptop_id, tab_seq)
  end

  def kata_file_edit(id:, files:, laptop_id:, tab_seq:)
    kata(id).file_edit(id, files, laptop_id, tab_seq)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id:, files:, stdout:, stderr:, status:, summary:, laptop_id:, tab_seq:)
    kata(id).ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
  end

  def kata_predicted_right(id:, files:, stdout:, stderr:, status:, summary:, laptop_id:, tab_seq:)
    kata(id).predicted_right(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
  end

  def kata_predicted_wrong(id:, files:, stdout:, stderr:, status:, summary:, laptop_id:, tab_seq:)
    kata(id).predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
  end

  def kata_reverted(id:, files:, stdout:, stderr:, status:, summary:, laptop_id:, tab_seq:)
    kata(id).reverted(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
  end

  def kata_checked_out(id:, files:, stdout:, stderr:, status:, summary:, laptop_id:, tab_seq:)
    kata(id).checked_out(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
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

  include EventIndex
  include IdPather
  include JsonAdapter

  # The id of kata id's group, its kata entry appended to result; id
  # itself when no kata has it.
  def kata_link(result, id)
    if kata_exists?(id:id)
      result << { 'type' => 'kata', 'id' => id }
      id = kata_manifest(id:id)['group_id']
    end
    id
  end

  # The id of group id's cluster, its group entry appended to result;
  # id itself when no group has it.
  def group_link(result, id)
    if group_exists?(id:id)
      result << { 'type' => 'group', 'id' => id }
      id = group_manifest(id:id)['cluster_id']
    end
    id
  end

  # Appends cluster id's entry to result when a cluster has it.
  def cluster_link(result, id)
    if cluster_exists?(id:id)
      result << { 'type' => 'cluster', 'id' => id }
    end
  end

  # result, the id-chain; a request error when it is empty.
  def existing_chain(result, id)
    # An empty result means the original id matched no kata, group or cluster
    # (id is only reassigned inside a block that also appends an entry). That is
    # a client error (400), not an empty hierarchy.
    if result.empty?
      fail RequestError, "id #{id} does not exist"
    end
    result
  end

  # The id of the group kata id, with manifest, is in; a request error
  # when it is in none.
  def fork_group_id(id, manifest)
    group_id = manifest['group_id']
    fail RequestError, "kata #{id} is not in a group" if group_id.nil?
    group_id
  end

  # The checkout naming light, at index of kata id with manifest, as
  # a forked avatar's summary records where it came from.
  def fork_checkout(id, index, light, manifest)
    {
      'id' => id,
      'index' => index,
      'major_index' => light['major_index'],
      'minor_index' => light['minor_index'],
      'avatarIndex' => manifest['group_index']
    }
  end

  # Gives avatar_id event's files and output, as light with checkout;
  # nothing when avatar_id is nil, the group being full.
  def check_out_avatar(avatar_id, event, light, checkout)
    unless avatar_id.nil?
      summary = { 'colour' => light['colour'], 'checkout' => checkout }
      kata(avatar_id).checked_out(avatar_id, event['files'], event['stdout'],
                                  event['stderr'], event['status'], summary, nil, nil)
    end
  end

  # The event at index of kata id, as avatar_fork forks it; a request
  # error unless it is a test result's traffic-light.
  def fork_light(id, index)
    light = kata_light(id, index)
    fail_unless_test_result(id, index, light)
    light
  end

  # A request error unless light, at index of kata id, is a test
  # result's traffic-light.
  def fail_unless_test_result(id, index, light)
    not_test_results = %w( create pulling timed_out faulty ) + PolyFiller::FILE_EVENTS
    if not_test_results.include?(light['colour'])
      fail RequestError, "kata #{id} event #{index} is not a traffic-light"
    end
  end

  # The event at index among kata id's events, a -ve index counting
  # back from the last; a request error when there is none.
  def kata_light(id, index)
    all_events = kata_events(id:id)
    pos_index = positive_index(index.to_i, all_events)
    fail_unless_in_range(index, pos_index, all_events)
    all_events[pos_index]
  end

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

  def kata_version(id)
    detected_version(id)
  rescue StandardError => error
    # Classify a failed version-detection: a well-formed but non-existent
    # kata-id is a client error (400), not the generic server error (500)
    # raised by from_path's manifest read. Real failures on a kata that does
    # exist are re-raised unchanged.
    raise error if kata_exists?(id:id)
    fail RequestError, "kata #{id} does not exist"
  end

  # A v2 kata is a git repo; v0/v1 are flat files. A .git stat is cheaper than
  # from_path's manifest read+parse, on a path hit by every kata operation.
  # Only v2 uses git, so .git present => v2; otherwise fall back to the legacy
  # manifest read.
  def detected_version(id)
    if disk.run(disk.dir_exists_command(kata_id_path(id, '.git')))
      2
    else
      legacy_version(id)
    end
  end

  # The version in a kata's manifest when it has no .git, which must be
  # v0 or v1 (a v2 without .git is an anomaly).
  def legacy_version(id)
    version = from_path(kata_id_path(id, 'manifest.json'))
    unless [0, 1].include?(version)
      fail "kata #{id} has no .git but manifest version is #{version}"
    end
    version
  end

  def from_manifest(manifest)
    # The creator's manifests come from start-points, which allow no
    # version key, so they use the current version. Only tests create
    # groups and katas at an older version.
    if manifest.key?('version')
      manifest['version'].to_i
    else
      CURRENT_VERSION
    end
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
