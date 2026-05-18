require_relative 'id_pather'
require_relative 'kata_v1'
require_relative 'not_implemented'
require_relative 'options'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

# 1. Manifest now has explicit version (1)
# 2. avatars() now does 1 read, not 64 reads.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.

class Group_v1

  def initialize(externals)
    @kata = Kata_v1.new(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = disk.assert(manifest_read_command(id))
    manifest = json_parse(manifest_src)
    polyfill_manifest_defaults(manifest)
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def joined(id)
    result = {}
    indexes = katas_indexes(id)
    # read the events summary file for each avatar
    read_events_files_commands = katas_ids(indexes).map do |kata_id|
      # eg reads file /cyber-dojo/katas/k5/ZT/k0/events.json
      @kata.send(:events_file_read_command, kata_id)
    end
    katas_events = disk.assert_all(read_events_files_commands)
    indexes.each.with_index(0) do |(group_index,kata_id),index|
      events = json_parse('[' + katas_events[index] + ']')
      polyfill_major_minor_events(events)
      result[group_index.to_s] = {
        'id' => kata_id,
        'events' => events
      }
    end
    result
  end

  private

  include IdPather
  include JsonAdapter
  include NotImplemented
  include Options
  include PolyFiller

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_ids(katas_indexes)
    katas_indexes.map{ |_,kata_id| kata_id }
  end

  def katas_indexes(id)
    katas_src = disk.assert(katas_read_command(id))
    # G2ws77 15
    # w34rd5 2
    # ...
    katas_src
      .split
      .each_slice(2)
      .map{|kata_id,group_index| [group_index.to_i,kata_id] }
      .sort
    # [
    #   [ 2, 'w34rd5'], #  2 == bat
    #   [15, 'G2ws77'], # 15 == fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_read_command(id)
    disk.file_read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_read_command(id)
    disk.file_read_command(katas_filename(id))
  end

  # - - - - - - - - - - - - - -
  # names of dirs/files

  def manifest_filename(id)
    group_id_path(id, 'manifest.json')
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj/manifest.json'
    # eg content ==> { "display_name": "Ruby, MiniTest", ... }
  end

  def katas_filename(id)
    group_id_path(id, 'katas.txt')
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj/katas.txt'
    # eg content ==>
    # SyG9sT 50
    # zhTLfa 32
  end

  # - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

end
