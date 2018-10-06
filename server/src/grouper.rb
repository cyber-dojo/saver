require 'json'

# If all ids came from a single server I could use
# 6-character ids as the directory names and guarantee
# uniqueness at id generation.
# However, it is not uncommon to copy practice-sessions
# from one server to another, and uniqueness cannot be
# guaranteed in this case.
# Hence a 'visible' id is 6-characters and is
# completed to a 'private' 10-character id.
# When entering an id you will almost always only need
# 6-characters, but very very occasionally you may need
# to enter a 7th,8th.
# Using a base58 alphabet (but excluding L)
#   ==> 3*10^10 unique  6-character ids.
#   ==> 3*10^16 unique 10-character ids.

class Grouper

  def initialize(externals)
    @externals = externals
  end

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest, files)
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
      invalid('id', id)
    end
    json = { manifest:manifest, files:files }
    dir[id].write(manifest_filename, json_pretty(json))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    assert_id_exists(id)
    get(id)[0]
  end

  # - - - - - - - - - - - - - - - - - - -

  def id?(id)
    dir[id].exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
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

  def joined(id)
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
