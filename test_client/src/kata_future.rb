# frozen_string_literal: true

require 'oj'

class KataFuture

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    saver.exists?(id_path(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    files = manifest.delete('visible_files')
    id = manifest['id'] = generate_id
    manifest['version'] = 2
    event0 = {
      'event' => 'created',
      'time' => manifest['created'],
      'index' => 0
    }
    saver.batch_until_false([
      manifest_write_cmd(id, manifest),
      events_write_cmd(id, event0),
      event_write_cmd(id, 0, { 'files' => files })
    ])
    # TODO: if result.include?(false)
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src,event0_src = saver.batch_read([
      manifest_read_cmd(id)[1],
      event_read_cmd(id, 0)[1]
    ])
    if [manifest_src,event0_src].include?(nil)
      fail invalid('id', id)
    end
    manifest = json_parse(manifest_src)
    event0 = json_parse(event0_src)
    manifest['visible_files'] = event0['files']
    manifest
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
    args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # create() extracts the visible_files from the manifest and
  # stores them as event-zero files. This allows a diff of the
  # first traffic-light but means manifest() has to recombine two
  # files. In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice, it doesn't work because the
  # start-point services can change over time.

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
  #
  # The visible-files are stored in a lined-format so they be easily
  # inspected on disk. Have to be unlined when read back.

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
  # json

  def json_plain(o)
    Oj.dump(o)
  end

  def json_parse(s)
    Oj.strict_load(s)
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    ArgumentError.new("#{name}:invalid:#{value}")
  end

  def saver
    @externals.saver
  end

  def id_generator
    @externals.id_generator
  end

end
