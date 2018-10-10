require 'json'

class Grouper

  def initialize(externals)
    @externals = externals
  end

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_exists?(id)
    dir[id].exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_create(manifest, files)
    if manifest['id'].nil?
      id = id_generator.generate
      manifest['id'] = id
    else
      id = manifest['id']
      unless id_validator.valid?(id)
        invalid('id', id)
      end
    end

    unless dir[id].make
      # :nocov:
      invalid('id', id)
      # :nocov:
    end

    json = { manifest:manifest, files:files }
    dir[id].write(manifest_filename, json_pretty(json))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_manifest(id)
    assert_id_exists(id)
    get(id)[0]
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    assert_id_exists(id)
    index = indexes.detect { |index|
      dir[id,index].make
    }
    if index.nil?
      nil
    else
      manifest,files = get(id)
      manifest.delete('id')
      manifest['group'] = id
      sid = singler.create(manifest, files)
      dir[id,index].write('id.json', json_pretty({ 'id' => sid }))
      [index, sid]
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_joined(id)
    assert_id_exists(id)
    result = {}
    64.times { |index|
      if dir[id,index].exists?
        json = json_parse(dir[id,index].read('id.json'))
        result[index] = json['id']
      end
    }
    result
  end

  private

  def get(id)
    json = json_parse(dir[id].read(manifest_filename))
    [json['manifest'],json['files']]
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def assert_id_exists(id)
    unless dir[id].exists?
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

  def invalid(name, value)
    fail ArgumentError.new("#{name}:invalid:#{value}")
  end

  # - - - - - - - - - - - - - -

  def dir
    @externals.disk
  end

  def id_generator
    @externals.id_generator
  end

  def id_validator
    @externals.id_validator
  end

  def singler
    @externals.singler
  end

end
