# frozen_string_literal: true

require_relative 'base58'
require_relative 'liner'
require 'json'

class Grouper

  def initialize(externals)
    @externals = externals
  end

  def ready?
    mapper.ready?
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_exists?(id)
    exist?(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_create(manifest)
    id = group_id(manifest)
    unless make?(id)
      fail invalid('id', id)
    end
    manifest['visible_files'] = lined_files(manifest['visible_files'])
    write(id, manifest_filename, json_pretty(manifest))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_manifest(id)
    assert_group_exists(id)
    manifest = json_parse(read(id, manifest_filename))
    manifest['visible_files'] = unlined_files(manifest['visible_files'])
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    assert_group_exists(id)
    index = indexes.detect { |new_index|
      make?(id, new_index)
    }
    if index.nil?
      nil
    else
      manifest = group_manifest(id)
      manifest.delete('id')
      manifest['group_id'] = id
      manifest['group_index'] = index
      kata_id = singler.kata_create(manifest)
      write(id, index, 'kata.id', kata_id)
      kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_joined(id)
    if !group_exists?(id)
      nil
    else
      kata_indexes(id).map{ |kata_id,_| kata_id }
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_events(id)
    if !group_exists?(id)
      events = nil
    else
      indexes = kata_indexes(id) # BatchMethod-1
      filenames = indexes.map do |kata_id,_index|
        args = ['', 'cyber-dojo', 'katas', kata_id[0..1], kata_id[2..3], kata_id[4..5]]
        args << 'events.json'
        File.join(*args)
      end
      katas_events = saver.reads(filenames) # BatchMethod-2
      # TODO: look into appending all the kata_events[] info
      # into a single string and then JSON.parsing that.
      # TODO: look into using a faster json parser...
      #       eg https://github.com/ohler55/oj
      events = {}
      indexes.each.with_index(0) do |(kata_id,index),offset|
        events[kata_id] = {
          'index' => index,
          'events' => katas_events[offset].lines.map do |line|
            JSON.parse!(line)
          end
        }
      end
    end
    events
  end

  private

  include Liner

  def group_id(manifest)
    # The manifest supplies the id only when the porter is porting
    # old storer architecture sessions to the new saver architecture
    # when it tries to maintain closely equivalent ids.
    # TODO: It would be nice to retire this porter requirement 
    # since it contains an obvious race condition when you then
    # go back to the saver with the make?() call.
    id = manifest['id']
    if id.nil?
      manifest['id'] = id = generate_id
    elsif group_exists?(id)
      fail invalid('id', id)
    end
    id
  end

  def kata_indexes(id)
    filenames = (0..63).map do |index|
      id_path(id, index, 'kata.id')
    end
    reads = saver.reads(filenames)
    reads.each.with_index(0).select{ |kata_id,_| kata_id }
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def assert_group_exists(id)
    unless group_exists?(id)
      fail invalid('id', id)
    end
  end

  # - - - - - - - - - - - - - -

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
      if id_validator.valid?(id)
        return id
      end
    end
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    ArgumentError.new("#{name}:invalid:#{value}")
  end

  # - - - - - - - - - - - - - -

  def exist?(id, *parts)
    saver.exist?(id_path(id, *parts))
  end

  def make?(id, *parts)
    saver.make?(id_path(id, *parts))
  end

  def write(id, *parts, content)
    saver.write(id_path(id, *parts), content)
  end

  def read(id, *parts)
    saver.read(id_path(id, *parts))
  end

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'cyber-dojo', 'groups', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - -

  def saver
    externals.disk
  end

  def id_validator
    externals.id_validator
  end

  def mapper
    externals.mapper
  end

  def singler
    externals.singler
  end

  attr_reader :externals

end
