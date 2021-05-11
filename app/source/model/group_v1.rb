# frozen_string_literal: true
require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'kata_v1'
require_relative 'options_checker'
require_relative 'poly_filler'
require_relative '../lib/json_adapter'

# 1. Manifest now has explicit version (1)
# 2. avatars() now does 1 read, not 64 reads.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.

class Group_v1

  def initialize(externals)
    @kata = Kata_v1.new(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create(manifest, options)
    fail_unless_known_options(options)
    manifest.merge!(options)
    manifest['version'] = 1
    manifest['created'] = time.now
    id = manifest['id'] = IdGenerator.new(@externals).group_id
    disk.assert_all(commands:[
      manifest_create_command(id, json_plain(manifest)),
      katas_create_command(id, '')
    ])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    unless IdGenerator::id?(id)
      return false
    end
    dir_name = group_id_path(id)
    command = disk.dir_exists_command(dir_name)
    disk.run(command:command)
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = disk.assert(command:manifest_read_command(id))
    manifest = json_parse(manifest_src)
    polyfill_manifest_defaults(manifest)
    json_plain(manifest)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    manifest = self.json_manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    # TODO: The code below was is when model was a separate service
    # and disk calls were made via http to saver. With model now
    # embedded inside saver this could probably be speeded up a lot
    # by doing a scandir() to filter the indexes that already have
    # a dir created.
    commands = indexes.map{ |index| dir_make_command(id, index) }
    results = disk.run_until_true(commands:commands)
    result_index = results.find_index(true)
    if result_index.nil?
      nil # full
    else
      index = indexes[result_index]
      manifest['group_index'] = index
      kata_id = @kata.create(manifest, {})
      disk.assert(command:katas_append_command(id, "#{kata_id} #{index}\n"))
      kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def joined(id)
    result = {}
    indexes = katas_indexes(id)
    # read the events summary file for each avatar
    read_events_files_commands = katas_ids(indexes).map do |kata_id|
      # eg reads file /cyber-dojo/katas/k5/ZT/k0/events.json
      @kata.send(:events_file_read_command, kata_id)
    end
    katas_events = disk.assert_all(commands:read_events_files_commands)
    indexes.each.with_index(0) do |(group_index,kata_id),index|
      result[group_index] = {
        'id' => kata_id,
        'events' => json_parse('[' + katas_events[index] + ']')
      }
    end
    json_plain(result)
  end

  private

  include IdPather
  include JsonAdapter
  include OptionsChecker
  include PolyFiller

  # - - - - - - - - - - - - - - - - - - - - - -

  def json_manifest(id)
    json_parse(manifest(id))
  end

  def katas_ids(katas_indexes)
    katas_indexes.map{ |_,kata_id| kata_id }
  end

  def katas_indexes(id)
    katas_src = disk.assert(command:katas_read_command(id))
    # G2ws77 15
    # w34rd5 2
    # ...
    katas_src
      .split
      .each_slice(2)
      .map{|kata_id,group_index| [group_index.to_i,kata_id] }
      .sort
    # [
    #   [ 2, 'w34rd5'], #  2 == bat
    #   [15, 'G2ws77'], # 15 == fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def dir_make_command(id, *parts)
    disk.dir_make_command(dir_name(id, *parts))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_create_command(id, manifest_src)
    disk.file_create_command(manifest_filename(id), manifest_src)
  end

  def manifest_read_command(id)
    disk.file_read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_create_command(id, src)
    disk.file_create_command(katas_filename(id), src)
  end

  def katas_append_command(id, src)
    disk.file_append_command(katas_filename(id), src)
  end

  def katas_read_command(id)
    disk.file_read_command(katas_filename(id))
  end

  # - - - - - - - - - - - - - -
  # names of dirs/files

  def dir_name(id, *parts)
    group_id_path(id, *parts)
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj'
  end

  def manifest_filename(id)
    group_id_path(id, 'manifest.json')
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj/manifest.json'
    # eg content ==> { "display_name": "Ruby, MiniTest", ... }
  end

  def katas_filename(id)
    group_id_path(id, 'katas.txt')
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj/katas.txt'
    # eg content ==>
    # SyG9sT 50
    # zhTLfa 32
  end

  # - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

  def time
    @externals.time
  end

end
