# frozen_string_literal: true

require_relative 'base58'
require_relative 'liner'
require 'json'

class Singler

  def initialize(saver)
    @saver = saver
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    saver.exist?(id_path(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_create(manifest)
    files = manifest.delete('visible_files')
    id = kata_id(manifest)
    event0 = {
      'event' => 'created',
      'time' => manifest['created']
    }
    saver.batch([
      make_cmd(id),
      make_cmd(id, 0),
      event_write_cmd(id, 0, { 'files' => files }),
      manifest_write_cmd(id, manifest),
      events_write_cmd(id, event0)
    ])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_manifest(id)
    kata_exists,manifest_src,event0_src = *saver.batch([
      exist_cmd(id),
      manifest_read_cmd(id),
      event_read_cmd(id, 0)
    ])
    unless kata_exists
      fail invalid('id', id)
    end
    manifest = json_parse(manifest_src)
    event0 = event_unpack(event0_src)
    manifest['visible_files'] = event0['files']
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
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
    unless index >= 1
      fail invalid('index', index)
    end
    results = saver.batch([
      exist_cmd(id),
      make_cmd(id, index),
      event_write_cmd(id, index, event_n),
      events_append_cmd(id, event_summary)
    ])
    unless results[0]
      fail invalid('id', id)
    end
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_events(id)
    # A cache of colours/time-stamps for all [test] events.
    # Helps optimize dashboard traffic-lights views.
    kata_exists,events = *saver.batch([
      exist_cmd(id),
      events_read_cmd(id)
    ])
    unless kata_exists
      fail invalid('id', id)
    end
    events.lines.map { |line|
      json_parse(line)
    }
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_event(id, index)
    if index === -1
      kata_exists,events_src = *saver.batch([
        exist_cmd(id),
        events_read_cmd(id)
      ])
      unless kata_exists
        fail invalid('id', id)
      end
      index = events_src.count("\n") - 1
      event_src = saver.batch([
        event_read_cmd(id, index)
      ])[0]
    else
      event_exists,event_src = *saver.batch([
        exist_cmd(id, index),
        event_read_cmd(id, index)
      ])
      unless event_exists
        fail invalid('index', index)
      end
    end
    event_unpack(event_src)
  end

  private

  attr_reader :saver

  def exist_cmd(id, *parts)
    ['exist?',id_path(id,*parts)]
  end

  def make_cmd(id, *parts)
    ['make?',id_path(id,*parts)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_write_cmd(id, manifest)
    ['write', id_path(id, manifest_filename), json_pretty(manifest)]
  end

  def manifest_read_cmd(id)
    ['read', id_path(id, manifest_filename)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

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

  def kata_id(manifest)
    id = manifest['id']
    if id.nil?
      manifest['id'] = id = generate_id
    elsif kata_exists?(id)
      fail invalid('id', id)
    end
    id
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

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'cyber-dojo', 'katas', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

end
