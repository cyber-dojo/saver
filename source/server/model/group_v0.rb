require_relative 'id_pather'
require_relative 'kata_v0'
require_relative 'not_implemented'
require_relative 'liner_v0'
require_relative 'options'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

class Group_v0

  def initialize(externals)
    @kata = Kata_v0.new(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest = json_manifest(id)
    polyfill_manifest_defaults(manifest)
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def joined(id)
    results = {}
    indexes = katas_indexes(id)
    # read the events summary file for each avatar
    read_events_files_commands = katas_ids(indexes).map do |kata_id|
      # eg reads file /cyber-dojo/katas/k5/ZT/k0/events.json
      @kata.send(:events_file_read_command, kata_id)
    end
    katas_events = disk.assert_all(read_events_files_commands)
    indexes.each.with_index(0) do |(group_index,kata_id),index|
      events = events_parse(katas_events[index])
      polyfill_events(events)
      polyfill_major_minor_events(events)
      results[group_index.to_s] = {
        'id' => kata_id,
        'events' => events
      }
    end
    results
  end

  private

  include IdPather
  include JsonAdapter
  include NotImplemented
  include Liner_v0
  include Options
  include PolyFiller

  # - - - - - - - - - - - - - - - - - - -

  def json_manifest(id)
    manifest_src = disk.assert(manifest_read_command(id))
    manifest = json_parse(manifest_src)
    manifest['visible_files'] = unlined_files(manifest['visible_files'])
    manifest
  end

  def katas_ids(katas_indexes)
    katas_indexes.map{ |_,kata_id| kata_id }
  end

  def katas_indexes(id)
    # In version-1 this is a single command
    read_commands = (0..63).map do |index|
      disk.file_read_command(kata_id_filename(id, index))
    end
    kata_ids = disk.run_all(read_commands)
    # kata_ids is an array of entries, eg
    # [
    #    nil,      # 0
    #    nil,      # 1
    #    'w34rd5', # 2
    #    nil,      # 3
    #    'G2ws77', # 4
    #    nil,      # 5
    #    ...
    # ]
    # indicating there are joined animals at group-indexes
    # 2 (bat) kata_id == w34rd5
    # 4 (bee) kata_id == G2ws77
    # etc
    kata_ids.filter_map
            .with_index(0) { |kata_id,group_index|
              [group_index,kata_id] if kata_id
            }
    # [
    #   [ 2,'w34rd5'], #  2 == bat
    #   [15,'G2ws77'], # 15 == fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_read_command(id)
    disk.file_read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - -
  # names of files

  def manifest_filename(id)
    group_id_path(id, 'manifest.json')
    # eg id == 'chy6BJ' ==> '/cyber-dojo/groups/ch/y6/BJ/manifest.json'
    # eg content ==> {"display_name":"Ruby, MiniTest",...}
  end

  def kata_id_filename(id, index)
    group_id_path(id, index, 'kata.id')
    # eg id == 'chy6BJ', index == 11 ==> '/cyber-dojo/groups/ch/y6/BJ/11/kata.id'
    # eg content ==> 'k5ZTk0'
  end

  # - - - - - - - - - - - - - -

  def events_parse(s)
    json_parse('[' + s.lines.join(',') + ']')
    # Alternative implementation, which tests show is slower.
    # s.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

end
