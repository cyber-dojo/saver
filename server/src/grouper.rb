require_relative 'id_generator'
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
      # :nocov:
      invalid('id', id)
      # :nocov:
    end
    dir.write(manifest_filename, json_pretty(manifest))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_manifest(id)
    assert_group_exists(id)
    json_parse(group_dir(id).read(manifest_filename))
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    assert_group_exists(id)
    index = indexes.detect { |index|
      group_dir(id,index).make
    }
    if index.nil?
      nil
    else
      manifest = group_manifest(id)
      manifest.delete('id')
      manifest['group'] = id
      sid = singler.kata_create(manifest)
      group_dir(id,index).write('id.json', json_pretty({ 'id' => sid }))
      [index, sid]
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_joined(id)
    if !group_exists?(id)
      result = nil
    else
      result = {}
      # TODO: globbing is going to be faster here I think
      64.times { |index|
        dir = group_dir(id, index)
        if dir.exists?
          json = json_parse(dir.read('id.json'))
          result[index] = json['id']
        end
      }
    end
    result
  end

  private

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
    # Using 2/2/2 split. See https://github.com/cyber-dojo/porter
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
    JSON.parse(s)
  end

  # - - - - - - - - - - - - - -

  def generate_id
    loop do
      id = IdGenerator.string(6)
      if !group_exists?(id)
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

end
