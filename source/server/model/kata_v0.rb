require_relative 'differ_diff'
require_relative 'fork'
require_relative 'id_pather'
require_relative 'not_implemented'
require_relative 'liner_v0'
require_relative 'options'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

class Kata_v0

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src,event0_src = disk.assert_all([
      manifest_file_read_command(id),
      event_file_read_command(id, 0)
    ])
    manifest = json_parse(manifest_src)
    event0 = unlined(json_parse(event0_src))
    polyfill_manifest(manifest, event0)
    polyfill_manifest_defaults(manifest)
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = disk.assert(events_file_read_command(id))
    result = json_parse('[' + result.lines.join(',') + ']')
    polyfill_events(result)
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
    all = disk.assert_all([
      events_file_read_command(id),
      event_file_read_command(id, index)
    ])
    events = json_parse('[' + all[0].lines.join(',') + ']')
    result = unlined(json_parse(all[1]))
    polyfill_event(result, events, index)
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event_batch(ids, indexes)
    result = {}

    commands = []
    (0...ids.size).each do |i|
      id = ids[i]
      index = indexes[i]
      commands << events_file_read_command(id)
      commands << event_file_read_command(id, index)
    end
    all = disk.assert_all(commands)

    (0...ids.size).each do |i|
      events = json_parse('[' + all[i*2].lines.join(',') + ']')
      j = unlined(json_parse(all[i*2+1]))
      id = ids[i]
      index = indexes[i]
      polyfill_event(j, events, index)
      result[id] ||= {}
      result[id][index.to_s] = j
    end

    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def file_create(id, files, filename, laptop_id)
    raise_not_implemented
  end

  def file_delete(id, files, filename, laptop_id)
    raise_not_implemented
  end

  def file_rename(id, files, old_filename, new_filename, laptop_id)
    raise_not_implemented
  end

  def file_edit(id, files, laptop_id)
    raise_not_implemented
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, files, stdout, stderr, status, summary, laptop_id)
    raise_not_implemented
  end

  def predicted_right(id, files, stdout, stderr, status, summary, laptop_id)
    raise_not_implemented
  end

  def predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id)
    raise_not_implemented
  end

  def reverted(id, files, stdout, stderr, status, summary, laptop_id)
    raise_not_implemented
  end

  def checked_out(id, files, stdout, stderr, status, summary, laptop_id)
    raise_not_implemented
  end

  def option_set(id, name, value)
    raise_not_implemented
  end

  include DifferDiff
  include Fork
  include Options

  private

  include IdPather
  include NotImplemented
  include JsonAdapter
  include Liner_v0
  include PolyFiller

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # Extracts the visible_files from the manifest and
  # stores them as event-zero files. This allows a diff of the
  # first traffic-light but means manifest() has to recombine two
  # files.

  def manifest_file_read_command(id)
    disk.file_read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events
  #
  # A cache of colours/time-stamps for all [test] events.
  # Helps optimize dashboard traffic-lights views.
  # Each event is stored as a single "\n" terminated line.
  # This is an optimization for universal_append() which need only
  # append to the end of the file.

  def events_file_read_command(id)
    disk.file_read_command(events_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event
  #
  # The visible-files are stored in a lined-format so they be easily
  # inspected on disk. Have to be unlined when read back.

  def event_file_read_command(id, index)
    disk.file_read_command(event_filename(id, index))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # names of dirs/files

  def manifest_filename(id)
    kata_id_path(id, 'manifest.json')
    # eg id == 'k5ZTk0' ==> '/cyber-dojo/katas/k5/ZT/k0/manifest.json'
    # eg content ==> {"display_name":"Ruby, MiniTest",...}
  end

  def events_filename(id)
    kata_id_path(id, 'events.json')
    # eg id == 'k5ZTk0' ==> '/cyber-dojo/katas/k5/ZT/k0/events.json'
    # eg content ==>
    # { "event": "created", "time": [ 2019,1,19,12,41, 0,406370 ] }
    # { "colour": "red",    "time": [ 2019,1,19,12,45,19,994317 ], "duration": 1.224763 }
    # { "colour": "amber",  "time": [ 2019,1,19,12,45,26,76791  ], "duration": 1.1275   }
    # { "colour": "green",  "time": [ 2019,1,19,12,45,30,656924 ], "duration": 1.072198 }
  end

  def event_filename(id, index)
    kata_id_path(id, index, 'event.json')
    # eg id == 'k5ZTk0', index == 2 ==> '/cyber-dojo/katas/k5/ZT/k0/2/event.json'
    # eg content ==>
    # {
    #   "files": {
    #     "hiker.rb": { "content": "......", "truncated": false },
    #     ...
    #   },
    #   "stdout": { "content": "...", "truncated": false },
    #   "stderr": { "content": "...", "truncated": false },
    #   "status": 1
    # }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

end
