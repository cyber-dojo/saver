# frozen_string_literal: true

require_relative 'kata'
require_relative 'liner'
require 'json'

class Group

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    saver.send(*exists_cmd(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = generate_id
    manifest['visible_files'] = lined_files(manifest['visible_files'])
    unless saver.send(*manifest_write_cmd(id, json_plain(manifest)))
      fail invalid('id', id) # TODO: cover this?
    end
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.send(*manifest_read_cmd(id))
    unless manifest_src.is_a?(String)
      fail invalid('id', id)
    end
    manifest = json_parse(manifest_src)
    manifest['visible_files'] = unlined_files(manifest['visible_files'])
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    manifest = self.manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    indexes.each do |index|
      if saver.send(*create_cmd(id, index))
        manifest['group_index'] = index
        kata_id = kata.create(manifest)
        saver.write(id_path(id, index, 'kata.id'), kata_id)
        return kata_id
      end
    end
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    if !exists?(id)
      nil
    else
      kata_indexes(id).map{ |kata_id,_| kata_id }
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    if !exists?(id)
      events = nil
    else
      indexes = kata_indexes(id)
      read_events_files_commands = indexes.map do |kata_id,_index|
        kata.send(:events_read_cmd, kata_id)
      end
      katas_events = saver.batch(read_events_files_commands)
      events = {}
      indexes.each.with_index(0) do |(kata_id,index),offset|
        events[kata_id] = {
          'index' => index,
          'events' => group_events_parse(katas_events[offset])
        }
      end
    end
    events
  end

  private

  def generate_id
    42.times do
      id = id_generator.id
      if saver.create(id_path(id))
        return id
      end
    end
  end

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'groups', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create_cmd(id, *parts)
    ['create', id_path(id, *parts)]
  end

  def exists_cmd(id)
    ['exists?', id_path(id)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_write_cmd(id, manifest_src)
    ['write', manifest_filename(id), manifest_src]
  end

  def manifest_read_cmd(id)
    ['read', manifest_filename(id)]
  end

  def manifest_filename(id)
    id_path(id, 'manifest.json')
  end

  # - - - - - - - - - - - - - - - - - - -

  include Liner

  def kata_indexes(id)
    read_commands = (0..63).map do |index|
      ['read', id_path(id, index, 'kata.id')]
    end
    reads = saver.batch(read_commands)
    # reads is an array of 64 entries, eg
    # [
    #    nil,      # 0
    #    nil,      # 1
    #    'w34rd5', # 2
    #    nil,      # 3
    #    'G2ws77', # 4
    #    nil
    #    ...
    # ]
    # indicating there are joined animals at indexes
    # 2 (bat) id == w34rd5
    # 4 (bee) id == G2ws77
    reads.each.with_index(0).select{ |kata_id,_| kata_id }
    # Select the non-nil entries whilst retaining the index
    # [ ['w34rd5',2], ['G2ws77',4], ... ]
  end

  # - - - - - - - - - - - - - -

  def group_events_parse(s)
    JSON.parse!('[' + s.lines.join(',') + ']')
    # Alternative implementation, which tests show is slower.
    # s.lines.map { |line| JSON.parse!(line) }
  end

  # - - - - - - - - - - - - - -

  def json_plain(o)
    JSON.fast_generate(o)
  end

  def json_parse(s)
    JSON.parse!(s)
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    ArgumentError.new("#{name}:invalid:#{value}")
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

  def id_generator
    @externals.id_generator
  end

  def kata
    @externals.kata
  end

end
