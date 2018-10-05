require_relative 'id_splitter'
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
#   ==> 3^10 unique  6-character ids.
#   ==> 3^16 unique 10-character ids.

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
    if manifest['id'].nil?
      id = id_generator.generate
      manifest['id'] = id
    else
      id = manifest['id']
      unless id_validator.valid?(id)
        invalid('id', id)
      end
    end
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
    args = [path, outer(partial_id), inner(partial_id)[0..3]]
    completions = disk[File.join(*args)].completions
    if completions.size == 1
      completions[0].split('/')[-2..-1].join
    else
      ''
    end
    #outer_dir = disk[dir_join(path, outer(partial_id))]
    #completions = outer_dir.completions
    #unless outer_dir.exists?
    #  return ''
    #end
    # Slower with more inner dirs.
    #dirs = outer_dir.each_dir.select { |inner_dir|
    #  inner_dir.start_with?(inner(partial_id))
    #}
    #unless dirs.length == 1
    #  return ''
    #end
    #outer(partial_id) + dirs[0] # success!
  end

  # - - - - - - - - - - - - - - - - - - -

=begin
  def id_completions(outer_id)
    # for Batch-Method iteration over large number of practice-sessions...
    unless disk[dir_join(path, outer_id)].exists?
      return []
    end
    disk[dir_join(path, outer_id)].each_dir.collect { |dir|
      outer_id + dir
    }
  end
=end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    assert_id_exists(id)
    index = indexes.detect { |n|
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
      invalid('id', id)
    end
  end

  def id_dir(id)
    disk[id_path(id)]
  end

  def id_path(id)
    dir_join(path, outer(id), inner(id))
  end

  include IdSplitter

  # - - - - - - - - - - - - - -

  def dir_join(*args)
    File.join(*args)
  end

  def invalid(name, value)
    fail ArgumentError.new("#{name}:invalid:#{value}")
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

  def id_validator
    @externals.id_validator
  end

  def singler
    @externals.singler
  end

end
