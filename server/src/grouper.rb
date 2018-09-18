require 'json'

class Grouper

  def initialize(externals)
    @externals = externals
    @path = '/persistent-dir/ids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = id_generator.generate
    manifest['id'] = id
    dir = id_dir(id)
    dir.make
    dir.write(manifest_filename, json_unparse(manifest))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    assert_id_exists(id)
    dir = id_dir(id)
    json_parse(dir.read(manifest_filename))
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
    'TODO'
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    assert_id_exists(id)
    'TODO'
  end

  # - - - - - - - - - - - - - - - - - - -

  private

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

end
