# frozen_string_literal: true

require_relative 'base58'
require_relative 'liner'
require 'json'

class Singler

  def initialize(disk)
    @disk = disk
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    exist?(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_create(manifest)
    files = manifest.delete('visible_files')
    id = kata_id(manifest)
    event_write(id, 0, { 'files' => files })
    write(id, manifest_filename, json_pretty(manifest))
    event0 = {
         'event' => 'created',
          'time' => manifest['created']
      }
    events_append(id, event0)
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_manifest(id)
    assert_kata_exists(id)
    manifest = json_parse(read(id, manifest_filename))
    manifest['visible_files'] = kata_event(id, 0)['files']
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    assert_kata_exists(id)
    unless index >= 1
      fail invalid('index', index)
    end
    event_write(id, index, {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    })
    events_append(id, { 'colour' => colour, 'time' => now, 'duration' => duration })
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_events(id)
    # A cache of colours/time-stamps for all [test] events.
    # Helps optimize dashboard traffic-lights views.
    assert_kata_exists(id)
    events_read(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_event(id, index)
    if index == -1
      assert_kata_exists(id)
      index = event_most_recent(id)
    else
      unless event_exists?(id, index)
        fail invalid('index', index)
      end
    end
    event_read(id, index)
  end

  private

  include Liner

  def kata_id(manifest)
    id = manifest['id']
    if id.nil?
      manifest['id'] = id = generate_id
    elsif kata_exists?(id)
      fail invalid('id', id)
    end
    id
  end

  def assert_kata_exists(id)
    unless kata_exists?(id)
      fail invalid('id', id)
    end
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -
  # events

  def events_append(id, event)
    append(id, events_filename, json_plain(event) + "\n")
  end

  def events_read(id)
    events_read_lined(id).lines.map{ |line|
      json_parse(line)
    }
  end

  def events_read_lined(id)
    read(id, events_filename)
  end

  def event_most_recent(id)
    events_read_lined(id).count("\n") - 1
  end

  def events_filename
    'events.json'
  end

  # - - - - - - - - - - - - - -
  # event

  def event_exists?(id, index)
    exist?(id, index)
  end

  def event_write(id, index, event)
    unless make?(id, index)
      fail invalid('index', index)
    end
    event['files'] = lined_files(event['files'])
    lined_file(event['stdout'])
    lined_file(event['stderr'])
    write(id, index, event_filename, json_pretty(event))
  end

  def event_read(id, index)
    event = json_parse(read(id, index, event_filename))
    event['files'] = unlined_files(event['files'])
    unlined_file(event['stdout'])
    unlined_file(event['stderr'])
    event
  end

  def event_filename
    'event.json'
  end

  # - - - - - - - - - - - - - -

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

  def generate_id
    loop do
      id = Base58.string(6)
      unless kata_exists?(id)
        return id
      end
    end
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    ArgumentError.new("#{name}:invalid:#{value}")
  end

  # - - - - - - - - - - - - - -

  def make?(id, *parts)
    disk.make?(id_path(id, *parts))
  end

  def exist?(id, *parts)
    disk.exist?(id_path(id, *parts))
  end

  def append(id, *parts, content)
    disk.append(id_path(id, *parts), content)
  end

  def write(id, *parts, content)
    disk.write(id_path(id, *parts), content)
  end

  def read(id, *parts)
    disk.read(id_path(id, *parts))
  end

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'cyber-dojo', 'katas', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  attr_reader :disk

end
