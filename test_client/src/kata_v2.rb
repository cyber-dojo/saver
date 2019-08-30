# frozen_string_literal: true

require_relative 'saver_exception'
require_relative 'oj_adapter'

# 1. Manifest now has explicit version.
# 2. No longer stores JSON in pretty format.
# 3. No longer stores file contents in lined format.
# 4. Uses Oj as its JSON gem.
# 5. Stores explicit index in events.json summary file.
#    This makes using index==-1 robust when traff-clights
#    are lost due to Saver outages.
#    was    { ... } # 0
#           { ... } # 1
#           { ... } # 4
#    now    { ... "index" => 0 }
#           { ... "index" => 1 }
#           { ... "index" => 4 }
# 6. No longer uses separate dir for each event file.
#    This makes ran_tests() faster as it no longer needs
#    a create_cmd() in its saver.batch call.
#    was     /cyber-dojo/katas/e3/T6/K2/0/event.json
#    now     /cyber-dojo/katas/e3/T6/K2/0.event.json

class Kata_v2

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    saver.exists?(id_path(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = generate_id
    manifest['version'] = 2
    event_summary = {
      'event' => 'created',
      'time' => manifest['created'],
      'index' => 0
    }
    # So you can diff against the first traffic-light.
    to_diff = {
      'files' => manifest['visible_files']
    }
    saver.batch_until_false([
      manifest_write_cmd(id, manifest),
      events_write_cmd(id, event_summary),
      event_write_cmd(id, 0, to_diff)
    ])
    # TODO: if result.include?(false)
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.send(*manifest_read_cmd(id))
    if manifest_src.nil?
      fail invalid('id', id)
    end
    json_parse(manifest_src)
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    unless index >= 1
      fail invalid('index', index)
    end
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    event_summary = {
      'colour' => colour,
      'time' => now,
      'duration' => duration,
      'index' => index
    }
    results = saver.batch_until_false([
      event_write_cmd(id, index, event_n),
      events_append_cmd(id, event_summary)
    ])
    if results.include?(false)
      fail invalid('index', index)
    end
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    events_src = saver.send(*events_read_cmd(id))
    if events_src.nil?
      fail invalid('id', id)
    end
    json_parse('[' + events_src.lines.join(',') + ']')
    # Alternative implementation, which profiling shows is slower.
    # events_src.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver.send(*events_read_cmd(id))
      if events_src.nil?
        fail invalid('id', id)
      end
      last_line = events_src.lines.last
      index = json_parse(last_line)['index']
    end
    event_src = saver.send(*event_read_cmd(id, index))
    if event_src.nil?
      fail invalid('index', index)
    end
    json_parse(event_src)
  end

  private

  include OjAdapter

  def id_generator
    @externals.id_generator
  end

  def generate_id
    loop do
      id = id_generator.id
      if saver.create(id_path(id))
        return id
      end
    end
  end

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['katas', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice it creates coupling, and it
  # doesn't work because start-point services change over time.

  def manifest_write_cmd(id, manifest)
    ['write', id_path(id, manifest_filename), json_plain(manifest)]
  end

  def manifest_read_cmd(id)
    ['read', id_path(id, manifest_filename)]
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  def event_write_cmd(id, index, event)
    ['write', id_path(id, event_filename(index)), json_plain(event)]
  end

  def event_read_cmd(id, index)
    ['read', id_path(id, event_filename(index))]
  end

  def event_filename(index)
    "#{index}.event.json"
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events
  #
  # A cache of colours/time-stamps for all [test] events.
  # Helps optimize dashboard traffic-lights views.
  # Each event is stored as a single "\n" terminated line.
  # This is an optimization for ran_tests() which need only
  # append to the end of the file.

  def events_write_cmd(id, event0)
    ['write', id_path(id, events_filename), json_plain(event0) + "\n"]
  end

  def events_append_cmd(id, event)
    ['append', id_path(id, events_filename), json_plain(event) + "\n"]
  end

  def events_read_cmd(id)
    ['read', id_path(id, events_filename)]
  end

  def events_filename
    'events.json'
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    SaverException.new(json_pretty({
      "message" => "#{name}:invalid:#{value}"
    }))
  end

  def saver
    @externals.saver
  end

end
