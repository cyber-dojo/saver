require 'json'

class Grouper

  def initialize(externals)
    @externals = externals
    @path = '/grouper/ids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest, files)
    id = id_generator.generate
    manifest['id'] = id
    dir = id_dir(id)
    dir.make
    dir.write(manifest_filename, json_unparse({
      manifest:manifest,
      files:files
    }))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    assert_id_exists(id)
    get(id)[0]
  end

  # - - - - - - - - - - - - - - - - - - -

  def id?(id)
    id_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_completed(partial_id)
    outer_dir = disk[dir_join(path, outer(partial_id))]
    unless outer_dir.exists?
      return ''
    end
    # Slower with more inner dirs.
    dirs = outer_dir.each_dir.select { |inner_dir|
      inner_dir.start_with?(inner(partial_id))
    }
    unless dirs.length == 1
      return ''
    end
    outer(partial_id) + dirs[0] # success!
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_completions(outer_id)
    # for Batch-Method iteration over large number of practice-sessions...
    unless disk[dir_join(path, outer_id)].exists?
      return []
    end
    disk[dir_join(path, outer_id)].each_dir.collect { |dir|
      outer_id + dir
    }
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id)
    assert_id_exists(id)
    index = (0..63).to_a.shuffle.detect { |n|
      path = dir_join(id_path(id), n.to_s)
      disk[path].make
    }
    if index.nil?
      nil
    else
      manifest,files = get(id)
      manifest.delete('id')
      manifest['group'] = id
      sid = singler.create(manifest, files)
      path = dir_join(id_path(id), index.to_s)
      dir = disk[path]
      dir.make
      dir.write('id.json', json_unparse({ 'id' => sid }))
      return [index, sid]
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    assert_id_exists(id)
    result = {}
    64.times { |index|
      path = dir_join(id_path(id), index.to_s)
      dir = disk[path]
      if dir.exists?
        json = json_parse(dir.read('id.json'))
        result[index] = json['id']
      end
    }
    result
  end

  private

  def get(id)
    json = json_parse(id_dir(id).read(manifest_filename))
    return [json['manifest'],json['files']]
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def assert_id_exists(id)
    unless id_dir(id).exists?
      invalid('id')
    end
  end

  def id_dir(id)
    disk[id_path(id)]
  end

  def id_path(id)
    dir_join(path, outer(id), inner(id))
  end

  def outer(id)
    id[0..1]  # 2-chars long. eg 'e5'
  end

  def inner(id)
    id[2..-1] # 8-chars long. eg '6aM327PE'
  end

  # - - - - - - - - - - - - - -

  def dir_join(*args)
    File.join(*args)
  end

  def invalid(name)
    fail ArgumentError.new("#{name}:invalid")
  end

  # - - - - - - - - - - - - - -

  def json_unparse(o)
    JSON.pretty_generate(o)
  end

  def json_parse(s)
    JSON.parse(s)
  end

  # - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

  def id_generator
    @externals.id_generator
  end

  def singler
    @externals.singler
  end

end
