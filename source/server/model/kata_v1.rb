require_relative 'differ_diff'
require_relative 'fork'
require_relative 'id_pather'
require_relative 'not_implemented'
require_relative 'options'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

# 1. Manifest now has explicit version (1)
# 2. Manifest is retrieved in single read call.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.
# 5. Uses Oj as its JSON gem.
# 6. Stores explicit index in events.json summary file.
#    This improves robustness when there are Saver outages.
#    For example index==-1.
#    was    { ... } #  0
#           { ... } #  1
#    then 2-23 outage
#           { ... } # 24
#    now    { ..., "index" =>  0 }
#           { ..., "index" =>  1 }
#           { ..., "index" => 24 }
# 7. No longer uses separate dir/ for each event file.
#    This makes ran_tests() faster as it no longer needs
#    a dir_make_command() in its disk.assert_all() call.
#    was     /cyber-dojo/katas/e3/T6/K2/0/event.json
#    now     /cyber-dojo/katas/e3/T6/K2/0.event.json

class Kata_v1

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = disk.assert(manifest_file_read_command(id))
    manifest = json_parse(manifest_src)
    polyfill_manifest_defaults(manifest)
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = json_parse('[' + disk.assert(events_file_read_command(id)) + ']')
    result[0]['colour'] = 'create'
    polyfill_major_minor_events(result)
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    index = index.to_i
    if index < 0
      all = events(id)
      index = all[index]['index']
    end
    result = json_parse(disk.assert(event_file_read_command(id, index)))
    # v1 stored 'truncated' in individual file entries; v2 does not.
    # Strip it so callers see a consistent file representation.
    result['files'].each_value { |f| f.delete('truncated') }
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event_batch(ids, indexes)
    result = {}

    commands = []
    (0...ids.size).each do |i|
      id = ids[i]
      index = indexes[i]
      commands << event_file_read_command(id, index)
    end
    all = disk.assert_all(commands)

    (0...ids.size).each do |i|
      j = json_parse(all[i])
      j['files'].each_value { |f| f.delete('truncated') } # see event()
      id = ids[i]
      index = indexes[i]
      result[id] ||= {}
      result[id][index.to_s] = j
    end

    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_create(id, index, files, filename)
    raise_not_implemented
  end

  def file_delete(id, index, files, filename)
    raise_not_implemented
  end

  def file_rename(id, index, files, old_filename, new_filename)
    raise_not_implemented
  end

  def file_edit(id, index, files)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    raise_not_implemented
  end

  def predicted_right(id, index, files, stdout, stderr, status, summary)
    raise_not_implemented
  end

  def predicted_wrong(id, index, files, stdout, stderr, status, summary)
    raise_not_implemented
  end

  def reverted(id, index, files, stdout, stderr, status, summary)
    raise_not_implemented
  end

  def checked_out(id, index, files, stdout, stderr, status, summary)
    raise_not_implemented
  end

  def option_set(id, name, value)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  include DifferDiff
  include Fork
  include Options

  private

  include IdPather
  include JsonAdapter
  include NotImplemented
  include PolyFiller

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice it creates coupling, and it
  # doesn't work anyway, since start-points change over time.

  def manifest_file_read_command(id)
    disk.file_read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events

  def events_file_read_command(id)
    disk.file_read_command(events_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  def event_file_read_command(id, index)
    disk.file_read_command(event_filename(id,index))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # names of dirs/files

  def manifest_filename(id)
    kata_id_path(id, 'manifest.json')
    # eg id == 'SyG9sT' ==> '/cyber-dojo/katas/Sy/G9/sT/manifest.json'
    # eg content ==> { "display_name": "Ruby, MiniTest",...}
  end

  def events_filename(id)
    kata_id_path(id, 'events.json')
    # eg id == 'SyG9sT' ==> '/cyber-dojo/katas/Sy/G9/sT/events.json'
    # eg content ==>
    # { "index": 0, ..., "event": "created" },
    # { "index": 1, ..., "colour": "red"    },
    # { "index": 2, ..., "colour": "amber"  },
  end

  def event_filename(id, index)
    kata_id_path(id, "#{index}.event.json")
    # eg id == 'SyG9sT', index == 2 ==> '/cyber-dojo/katas/Sy/G9/sT/2.event.json'
    # eg content ==>
    # {
    #   "files": {
    #     "hiker.rb": { "content": "......", "truncated": false },
    #     ...
    #   },
    #   "stdout": { "content": "...", "truncated": false },
    #   "stderr": { "content": "...", "truncated": false },
    #   "status": 1,
    #   "index": 2,
    #   "time": [ 2020,3,27,11,56,7,719235 ],
    #   "duration": 1.064011,
    #   "colour": "amber"
    # }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

end
