require_relative 'base58'
require 'json'

class Singler

  def initialize(disk)
    @disk = disk
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    kata_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_create(manifest)
    files = manifest.delete('visible_files')
    id = kata_id(manifest)
    dir = kata_dir(id)
    tag_write(id, 0, files, '', '', 0)
    dir.write(manifest_filename, json_pretty(manifest))
    tag0 = {
         'event' => 'created',
          'time' => manifest['created'],
        'number' => 0
      }
    tags_append(id, tag0)
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_manifest(id)
    assert_kata_exists(id)
    manifest = json_parse(kata_dir(id).read(manifest_filename))
    manifest['visible_files'] = kata_tag(id, 0)['files']
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
    assert_kata_exists(id)
    unless n >= 1
      invalid('n', n)
    end

    tag_write(id, n, files, stdout, stderr, status)
    tag = { 'colour' => colour, 'time' => now, 'number' => n }
    tags_append(id, tag)

    tags_read(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_tags(id)
    assert_kata_exists(id)
    tags_read(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_tag(id, n)
    if n == -1
      assert_kata_exists(id)
      n = tag_most_recent(id)
    else
      unless tag_exists?(id, n)
        invalid('n', n)
      end
    end
    tag_read(id, n)
  end

  private

  def kata_id(manifest)
    id = manifest['id']
    if id.nil?
      manifest['id'] = id = generate_id
    elsif kata_exists?(id)
      invalid('id', id)
    end
    id
  end

  def assert_kata_exists(id)
    unless kata_exists?(id)
      invalid('id', id)
    end
  end

  def kata_dir(id, index=nil)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
    unless index.nil?
      args << index.to_s
    end
    @disk[File.join(*args)]
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def tags_append(id, tag)
    kata_dir(id).append(tags_filename, json_plain(tag) + "\n")
  end

  def tags_read(id)
    tags_read_lined(id).lines.map{ |line|
      json_parse(line)
    }
  end

  def tags_read_lined(id)
    kata_dir(id).read(tags_filename)
  end

  def tags_filename
    'tags.json'
  end

  # - - - - - - - - - - - - - -

  def tag_exists?(id, n)
    kata_dir(id, n).exists?
  end

  def tag_write(id, n, files, stdout, stderr, status)
    dir = kata_dir(id,n)
    unless dir.make
      invalid('n', n)
    end
    json = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    dir.write(tag_filename, json_pretty(json))
  end

  def tag_read(id, n)
    json_parse(kata_dir(id,n).read(tag_filename))
  end

  def tag_most_recent(id)
    tags_read_lined(id).count("\n") - 1
  end

  def tag_filename
    'tag.json'
  end

  # - - - - - - - - - - - - - -

  def json_plain(o)
    JSON.generate(o)
  end

  def json_pretty(o)
    JSON.pretty_generate(o)
  end

  def json_parse(s)
    JSON.parse(s)
  end

  # - - - - - - - - - - - - - -

  def generate_id
    loop do
      id = Base58.string(6)
      if !kata_exists?(id)
        return id
      end
    end
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    fail ArgumentError.new("#{name}:invalid:#{value}")
  end

end
