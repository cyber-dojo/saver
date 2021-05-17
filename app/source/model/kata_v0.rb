# frozen_string_literal: true
require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'liner_v0'
require_relative 'options_checker'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

class Kata_v0

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    unless IdGenerator::id?(id)
      return false
    end
    dir_name = kata_id_path(id)
    command = disk.dir_exists_command(dir_name)
    disk.run(command)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest, options)
    manifest = manifest.clone
    fail_unless_known_options(options)
    manifest.merge!(options)
    manifest['version'] = 0
    manifest['created'] = time.now
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    files = manifest.delete('visible_files')
    event0 = {
      'event' => 'created',
      'time' => manifest['created']
    }
    disk.assert_all([
      dir_make_command(id, 0),
      manifest_file_create_command(id, json_plain(manifest)),
      event_file_create_command(id, 0, json_plain(lined({ 'files' => files }))),
      events_file_create_command(id, json_plain(event0) + "\n")
    ])
    id
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
    json = json_parse('[' + result.lines.join(',') + ']')
    polyfill_events(json)
    json
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    index = index.to_i
    if index < 0
      all = events(id)
      index = all[index]['index']
    end
    results = disk.assert_all([
      events_file_read_command(id),
      event_file_read_command(id, index)
    ])
    events = json_parse('[' + results[0].lines.join(',') + ']')
    json = unlined(json_parse(results[1]))
    polyfill_event(json, events, index)
    json
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def event_batch(ids, indexes)
    json = {}

    commands = []
    (0...ids.size).each do |i|
      id = ids[i]
      index = indexes[i]
      commands << events_file_read_command(id)
      commands << event_file_read_command(id, index)
    end
    results = disk.assert_all(commands)

    (0...ids.size).each do |i|
      events = json_parse('[' + results[i*2].lines.join(',') + ']')
      j = unlined(json_parse(results[i*2+1]))
      id = ids[i]
      index = indexes[i]
      polyfill_event(j, events, index)
      json[id] ||= {}
      json[id][index.to_s] = j
    end

    json
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def predicted_right(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def predicted_wrong(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def reverted(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  def checked_out(id, index, files, stdout, stderr, status, summary)
    universal_append(id, index, files, stdout, stderr, status, summary)
  end

  private

  include IdPather
  include JsonAdapter
  include Liner_v0
  include OptionsChecker
  include PolyFiller

  def universal_append(id, index, files, stdout, stderr, status, summary)
    summary['time'] = time.now
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    result = disk.assert_all([
      # A failing make_command() ensures the append_command() is not run.
      dir_exists_command(id),
      dir_make_command(id, index),
      event_file_create_command(id, index, json_plain(lined(event_n))),
      events_file_append_command(id, json_plain(summary) + "\n")
    ])
    result
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def dir_make_command(id, *parts)
    disk.dir_make_command(dir_name(id, *parts))
  end

  def dir_exists_command(id, *parts)
    disk.dir_exists_command(dir_name(id, *parts))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # Extracts the visible_files from the manifest and
  # stores them as event-zero files. This allows a diff of the
  # first traffic-light but means manifest() has to recombine two
  # files.

  def manifest_file_create_command(id, manifest_src)
    disk.file_create_command(manifest_filename(id), manifest_src)
  end

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

  def events_file_create_command(id, event0_src)
    disk.file_create_command(events_filename(id), event0_src)
  end

  def events_file_append_command(id, eventN_src)
    disk.file_append_command(events_filename(id), eventN_src)
  end

  def events_file_read_command(id)
    disk.file_read_command(events_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event
  #
  # The visible-files are stored in a lined-format so they be easily
  # inspected on disk. Have to be unlined when read back.

  def event_file_create_command(id, index, event_src)
    disk.file_create_command(event_filename(id, index), event_src)
  end

  def event_file_read_command(id, index)
    disk.file_read_command(event_filename(id, index))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # names of dirs/files

  def dir_name(id, *parts)
    kata_id_path(id, *parts)
    # eg id == 'k5ZTk0', parts = [  ] ==> '/cyber-dojo/katas/k5/ZT/k0'
    # eg id == 'k5ZTk0', parts = [31] ==> '/cyber-dojo/katas/k5/ZT/k0/31'
  end

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

  def time
    @externals.time
  end

end
