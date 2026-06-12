require_relative 'group_v2'
require_relative 'id_generator'
require_relative 'id_pather'
require_relative '../request_error'
require_relative '../lib/json_adapter'

# A cluster is the umbrella over a multi-LTF practice. It holds the group-wide
# exercise and references its child groups (one ordinary Group_v2 per LTF). It
# is NOT a group and is never joined directly; joining resolves to a child group.
class Cluster

  # Stores the externals (disk, time, random, ...) used to persist the cluster.
  def initialize(externals)
    @externals = externals
  end

  # Creates the cluster: generates its id, creates one Group_v2 child per ltf
  # (each carrying cluster_id), stores the cluster referencing the children, and
  # returns the cluster id. A cluster offers 2..4 LTFs (a single-LTF practice is a
  # bare Group_v2, not a cluster), so any other ltfs.size raises RequestError.
  def create(manifest)
    ltfs = manifest.fetch('ltfs')
    unless (2..4).include?(ltfs.size)
      fail RequestError, "ltfs.size:#{ltfs.size}: (a cluster offers 2..4 LTFs)"
    end
    id = IdGenerator.new(@externals).cluster_id
    children = ltfs.map do |ltf|
      group_id = Group_v2.new(@externals).create(ltf.merge('cluster_id' => id))
      { 'ltf_display_name' => ltf['display_name'], 'group_id' => group_id }
    end
    disk.assert(manifest_create_command(id, json_plain({
      'id'       => id,
      'created'  => time.now,
      'exercise' => manifest['exercise'],
      'children' => children
    })))
    id
  end

  # Returns the cluster's stored manifest (exercise + children).
  def manifest(id)
    json_parse(disk.assert(manifest_read_command(id)))
  end

  private

  include IdPather
  include JsonAdapter

  # Command that writes the cluster's manifest.json.
  def manifest_create_command(id, src)
    disk.file_create_command(manifest_filename(id), src)
  end

  # Command that reads the cluster's manifest.json.
  def manifest_read_command(id)
    disk.file_read_command(manifest_filename(id))
  end

  # Absolute path of the cluster's manifest.json, eg
  # /cyber-dojo/clusters/wA/tC/fj/manifest.json
  def manifest_filename(id)
    cluster_id_path(id, 'manifest.json')
  end

  # The disk service.
  def disk
    @externals.disk
  end

  # The time service.
  def time
    @externals.time
  end

end
