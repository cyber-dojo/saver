require_relative 'base58'
require_relative 'liner'
require 'json'

class Grouper

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_exists?(id)
    group_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_create(manifest)
    id = group_id(manifest)
    dir = group_dir(id)
    unless dir.make
      invalid('id', id)
    end
    manifest['visible_files'] = lined(manifest['visible_files'])
    dir.write(manifest_filename, json_pretty(manifest))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_manifest(id)
    assert_group_exists(id)
    manifest = json_parse(group_dir(id).read(manifest_filename))
    manifest['visible_files'] = unlined(manifest['visible_files'])
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    assert_group_exists(id)
    index = indexes.detect { |new_index|
      group_dir(id,new_index).make
    }
    if index.nil?
      nil
    else
      manifest = group_manifest(id)
      manifest.delete('id')
      manifest['group_id'] = id
      manifest['group_index'] = index
      kata_id = singler.kata_create(manifest)
      group_dir(id,index).write('kata.id', kata_id)
      kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_joined(id)
    if !group_exists?(id)
      kata_ids = nil
    else
      kata_ids = []
      64.times { |index|
        dir = group_dir(id, index)
        if dir.exists?
          kata_id = dir.read('kata.id')
          kata_ids << kata_id
        end
      }
    end
    kata_ids
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_events(id)
    if !group_exists?(id)
      events = nil
    else
      events = {}
      64.times { |index|
        dir = group_dir(id, index)
        if dir.exists?
          kata_id = dir.read('kata.id')
          events[kata_id] = {
            'index' => index,
            'events' => singler.kata_events(kata_id)
          }
        end
      }
    end
    events
  end

  private

  include Liner

  def group_id(manifest)
    id = manifest['id']
    if id.nil?
      manifest['id'] = id = generate_id
    elsif group_exists?(id)
      invalid('id', id)
    end
    id
  end

  def group_dir(id, index=nil)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'groups', id[0..1], id[2..3], id[4..5]]
    unless index.nil?
      args << index.to_s
    end
    disk[File.join(*args)]
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def assert_group_exists(id)
    unless group_exists?(id)
      invalid('id', id)
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
    fail ArgumentError.new("#{name}:invalid:#{value}")
  end

  # - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

  def singler
    @externals.singler
  end

  def id_validator
    @externals.id_validator
  end

end
