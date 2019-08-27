# frozen_string_literal: true

require_relative 'liner'
require 'json'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Representation
#
# manifest.json
#   The visible_files are extracted and stored as event-zero files.
#   This allows a diff of the first traffic-light but means
#   kata_manifest() has to recombine two files. In theory the
#   manifest could store only the display_name and exercise_name and
#   be recreated, on-demand, from the relevant start-point services.
#   In practice, it doesn't work because the start-point services can
#   change over time.
#
# event.json (Individual event)
#   The visible-files are stored in a lined-format so they be easily
#   inspected on disk. Have to be unlined when read back.
#
# events.json (All events)
#   A cache of colours/time-stamps for all [test] events.
#   Helps optimize dashboard traffic-lights views.
#   Each event is stored as a single "\n" terminated line.
#   This is an optimization for kata_ran_tests() which need only
#   append to the end of the file.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Kata

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
    id = manifest['id'] = kata_id_generator.id
    event0 = {
      'event' => 'created',
      'time' => manifest['created']
    }
    saver.batch_until_false([
      manifest_write_cmd(id, manifest),
      events_write_cmd(id, event0),
      event_write_cmd(id, 0, { 'files' => files })
    ])
    # TODO: check saver.batch() result === [true]*3
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src,event0_src = saver.batch_read([
      id_path(id, manifest_filename),
      id_path(id, 0, event_filename)
    ])
    if [manifest_src,event0_src].include?(nil)
      fail invalid('id', id)
    end
    manifest = json_parse(manifest_src)
    event0 = event_unpack(event0_src)
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
      'duration' => duration
    }
    results = saver.batch_until_false([
      exists_cmd(id),
      event_write_cmd(id, index, event_n),
      events_append_cmd(id, event_summary)
    ])
    # TODO: check results === [true]*4
    unless results[0]
      fail invalid('id', id)
    end
    unless results[1]
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
    # Alternative implementation, which tests show is slower.
    # events_src.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver.send(*events_read_cmd(id))
      if events_src.nil?
        fail invalid('id', id)
      end
      index = events_src.count("\n") - 1
    end
    event_src = saver.send(*event_read_cmd(id, index))
    if event_src.nil?
      fail invalid('index', index)
    end
    event_unpack(event_src)
  end

  private

  def exists_cmd(id, *parts)
    ['exists?', id_path(id, *parts)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest

  def manifest_write_cmd(id, manifest)
    ['write', id_path(id, manifest_filename), json_pretty(manifest)]
  end

  def manifest_read_cmd(id)
    ['read', id_path(id, manifest_filename)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  include Liner

  def event_write_cmd(id, index, event)
    event['files'] = lined_files(event['files'])
    lined_file(event['stdout'])
    lined_file(event['stderr'])
    ['write', id_path(id, index, event_filename), json_pretty(event)]
  end

  def event_read_cmd(id, index)
    ['read', id_path(id, index, event_filename)]
  end

  def event_unpack(event_src)
    event = json_parse(event_src)
    event['files'] = unlined_files(event['files'])
    unlined_file(event['stdout'])
    unlined_file(event['stderr'])
    event
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events

  def events_write_cmd(id, event0)
    ['write', id_path(id, events_filename), json_plain(event0) + "\n"]
  end

  def events_append_cmd(id, event)
    ['append', id_path(id, events_filename), json_plain(event) + "\n"]
  end

  def events_read_cmd(id)
    ['read', id_path(id, events_filename)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - -
  # filenames

  def manifest_filename
    'manifest.json'
  end

  def events_filename
    'events.json'
  end

  def event_filename
    'event.json'
  end

  # - - - - - - - - - - - - - -
  # json

  def json_plain(o)
    JSON.fast_generate(o)
  end

  def json_pretty(o)
    JSON.pretty_generate(o)
  end

  def json_parse(s)
    JSON.parse!(s)
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    ArgumentError.new("#{name}:invalid:#{value}")
  end

  def saver
    @externals.saver
  end

  def kata_id_generator
    @externals.kata_id_generator
  end

end
