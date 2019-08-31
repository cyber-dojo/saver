# frozen_string_literal: true

require_relative 'saver_exception'
require_relative 'oj_adapter'

# 1. Manifest now has explicit version.
# 2. No longer stores JSON in pretty format.
# 3. No longer stores file contents in lined format.
# 4. joined() now does a single read rather than 64.
# 5. Uses Oj as its JSON gem.

class Group_v2

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
    manifest['version'] = 2
    results = saver.batch_until_false([
      manifest_write_cmd(id, manifest),
      katas_write_cmd(id)
    ])
    unless results === [true,true]
      fail invalid('id', id)
    end
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.send(*manifest_read_cmd(id))
    unless manifest_src
      fail invalid('id', id)
    end
    json_parse(manifest_src)
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
        saver.send(*katas_append_cmd(id, kata_id, index))
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
      kindexes = kata_indexes(id)
      filenames = kindexes.map do |kata_id,_index|
        kata.send(:events_read_cmd, kata_id)[1]
      end
      katas_events = saver.batch_read(filenames)
      events = {}
      kindexes.each.with_index(0) do |(kata_id,index),offset|
        events[kata_id] = {
          'index' => index.to_i,
          'events' => group_events_parse(katas_events[offset])
        }
      end
    end
    events
  end

  private

  include OjAdapter

  def generate_id
    loop do
      id = id_generator.id
      if saver.create(id_path(id))
        return id
      end
    end
  end

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['groups', id[0..1], id[2..3], id[4..5]]
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

  def manifest_write_cmd(id, manifest)
    ['write', id_path(id, manifest_filename), json_plain(manifest)]
  end

  def manifest_read_cmd(id)
    ['read', id_path(id, manifest_filename)]
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_write_cmd(id)
    ['write', id_path(id, katas_filename), '']
  end

  def katas_append_cmd(id, kata_id, index)
    ['append', id_path(id, katas_filename), "#{kata_id} #{index}\n"]
  end

  def katas_read_cmd(id)
    ['read', id_path(id, katas_filename)]
  end

  def katas_filename
    'katas.txt'
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_indexes(id)
    katas_src = saver.send(*katas_read_cmd(id))
    katas_src.split.each_slice(2).to_a
    # [
    #   ['w34rd5','2'],  # 2==bat
    #   ['G2ws77','15'], # 15=fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - -

  def group_events_parse(s)
    json_parse('[' + s.lines.join(',') + ']')
    # Alternative implementation, which tests show is slower.
    # s.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    SaverException.new(json_pretty({
      "message" => "#{name}:invalid:#{value}"
    }))
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
