require_relative 'base58'
require_relative 'http_json/request_error'
require 'json'

class HttpJsonArgs

  # Checks for arguments synactic correctness
  # Exception messages use the words 'body' and 'path'
  # to match RackDispatcher's exception keys.

  def initialize(externals, body)
    @externals = externals
    @args = JSON.parse!(body)
    unless @args.is_a?(Hash)
      fail HttpJson::RequestError, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
    fail HttpJson::RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path)
    env = @externals.env
    grouper = @externals.grouper
    singler = @externals.singler
    args = case path
    when '/ready'          then [grouper, 'ready?']
    when '/sha'            then [env, 'sha']

    when '/group_exists'   then [grouper, 'group_exists?', id]
    when '/group_create'   then [grouper, 'group_create', manifest]
    when '/group_manifest' then [grouper, 'group_manifest', id]
    when '/group_join'     then [grouper, 'group_join', id, indexes]
    when '/group_joined'   then [grouper, 'group_joined', id]
    when '/group_events'   then [grouper, 'group_events', id]

    when '/kata_exists'    then [singler, 'kata_exists?', id]
    when '/kata_create'    then [singler, 'kata_create', manifest]
    when '/kata_manifest'  then [singler, 'kata_manifest', id]
    when '/kata_ran_tests' then [singler, 'kata_ran_tests', id, index, files, now, duration, stdout, stderr, status, colour]
    when '/kata_events'    then [singler, 'kata_events', id]
    when '/kata_event'     then [singler, 'kata_event', id, index]
    else
      fail HttpJson::RequestError, 'unknown path'
    end
    target = args.shift
    name = args.shift
    [target, name, args]
  end

  def manifest
    arg = @args['manifest']
    unless arg.is_a?(Hash)
      malformed('manifest', "!Hash (#{arg.class.name})")
    end
    missing_key?(arg) do |key|
      malformed("manifest[#{key.inspect}]", 'missing')
    end
    unknown_key?(arg) do |key|
      malformed("manifest[#{key.inspect}]", 'unknown')
    end
    arg.keys.each do |key|
      arg_name = "manifest[#{key.inspect}]"
      value = arg[key]
      case key
      when 'created'
        well_formed_time(arg_name, value)
      when 'id','group'
        well_formed_id(arg_name, value)
      when 'display_name', 'exercise'
        well_formed_string(arg_name, value)
      when 'image_name'
        well_formed_string(arg_name, value)
      when 'visible_files'
        well_formed_files(arg_name, value)
      when 'filename_extension'
        well_formed_filename_extension(arg_name, value)
      when 'highlight_filenames','progress_regexs','hidden_filenames'
        well_formed_array_of_strings(arg_name, value)
      when 'tab_size'
        well_formed_tab_size(arg_name, value)
      when 'max_seconds'
        well_formed_max_seconds(arg_name, value)
      end
    end
    arg
  end

  attr_reader :args

  # - - - - - - - - - - - - - - - -

  def id
    well_formed_id('id', args['id'])
  end

  def indexes
    well_formed_indexes('indexes', args['indexes'])
  end

  def index
    well_formed_index('index', args['index'])
  end

  def files
    well_formed_files('files', args['files'])
  end

  def now
    well_formed_time('now', args['now'])
  end

  def duration
    well_formed_duration('duration', args['duration'])
  end

  def stdout
    well_formed_file('stdout', args['stdout'])
  end

  def stderr
    well_formed_file('stderr', args['stderr'])
  end

  def status
    well_formed_status('status', args['status'])
  end

  def colour
    well_formed_colour('colour', args['colour'])
  end

  private

  def missing_key?(manifest)
    REQUIRED_KEYS.each do |key|
      unless manifest.keys.include?(key)
        yield key
      end
    end
  end

  REQUIRED_KEYS = %w(
    display_name
    image_name
    created
    visible_files
  )

  # - - - - - - - - - - - - - - - -

  def unknown_key?(manifest)
    manifest.keys.each do |key|
      unless KNOWN_KEYS.include?(key)
        yield key
      end
    end
  end

  KNOWN_KEYS = REQUIRED_KEYS + %w(
    id
    group
    exercise
    filename_extension
    highlight_filenames
    hidden_filenames
    progress_regexs
    tab_size
    max_seconds
  )

  # - - - - - - - - - - - - - - - -

  def well_formed_filename_extension(arg_name, arg)
    if arg.is_a?(String)
      arg = [ arg ]
    end
    well_formed_array_of_strings(arg_name, arg)
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_tab_size(arg_name, arg)
    unless arg.is_a?(Integer)
      malformed(arg_name, '!Integer')
    end
    unless (1..8).include?(arg)
      malformed(arg_name, "!(1..8)")
    end
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_max_seconds(arg_name, arg)
    unless arg.is_a?(Integer)
      malformed(arg_name, '!Integer')
    end
    unless (1..20).include?(arg)
      malformed(arg_name, "!(1..20)")
    end
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_duration(arg_name, arg)
    unless arg.is_a?(Float)
      malformed(arg_name, '!Float')
    end
    unless arg >= 0.0
      malformed(arg_name, '!(>= 0.0)')
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_id(arg_name, arg)
    unless Base58.string?(arg)
      malformed(arg_name, '!Base58')
    end
    unless arg.size == 6
      malformed(arg_name, "size==#{arg.size} -> !6")
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_files(arg_name, arg)
    unless arg.is_a?(Hash)
      malformed(arg_name, "!Hash (#{arg.class.name})")
    end
    arg.each { |filename,file|
      # arg is generated by JSON.parse!()
      # and json hash keys can _only_ be strings
      # so no need to check filename
      unless file.is_a?(Hash)
        malformed(arg_name, "[#{filename.inspect}] !Hash (#{file.class.name})")
      end
      unless file.has_key?('content')
        malformed(arg_name, "[#{filename.inspect}][\"content\"] missing")
      end
      content = file['content']
      unless content.is_a?(String)
        malformed(arg_name, "[#{filename.inspect}][\"content\"] -> !String (#{content.class.name})")
      end
      # TODO: add content.size limit
    }
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_file(arg_name, arg)
    unless arg.is_a?(Hash)
      malformed(arg_name, "!Hash (#{arg.class.name})")
    end
    unless arg.has_key?('content')
      malformed(arg_name, '["content"] missing')
    end
    content = arg['content']
    unless content.is_a?(String)
      malformed(arg_name, "[\"content\"] -> !String (#{content.class.name})")
    end
    # TODO: add content.size limit
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_status(arg_name, arg)
    unless arg.is_a?(Integer)
      malformed(arg_name, '!Integer')
    end
    unless (0..255).include?(arg)
      malformed(arg_name, '!(0..255)')
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_indexes(arg_name, arg)
    unless arg.is_a?(Array)
      malformed(arg_name, '!Array')
    end
    unless arg.length == 64
      malformed(arg_name, "size==#{arg.size} -> !64")
    end
    unless arg.sort == (0..63).to_a
      malformed(arg_name, '!(0..63)')
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_index(arg_name, arg)
    unless arg.is_a?(Integer)
      malformed(arg_name, '!Integer')
    end
    unless arg >= -1
      malformed(arg_name, 'argument out of range')
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_time(arg_name, arg)
    unless arg.is_a?(Array)
      malformed(arg_name, '!Array')
    end
    unless arg.size == 7
      malformed(arg_name, "size==#{arg.size} -> !7")
    end
    arg.each_with_index do |n,index|
      unless n.is_a?(Integer)
        malformed(arg_name, "[#{index}] -> !Integer")
      end
    end
    well_formed_mktime(arg_name, arg)
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_mktime(arg_name, arg)
    Time.mktime(*arg)
    arg
  rescue => error
    malformed(arg_name, error.message)
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_colour(arg_name, arg)
    unless arg.is_a?(String)
      malformed(arg_name, '!String')
    end
    unless ['red','amber','green','timed_out'].include?(arg)
      malformed(arg_name, "!['red'|'amber'|'green'|'timed_out']")
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_array_of_strings(arg_name, arg)
    unless arg.is_a?(Array)
      malformed(arg_name, '!Array')
    end
    arg.each_with_index do |value,index|
      unless value.is_a?(String)
        malformed(arg_name, "[#{index}] -> !String")
      end
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def well_formed_string(arg_name, arg)
    unless arg.is_a?(String)
      malformed(arg_name, '!String')
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def malformed(arg_name, msg)
    raise HttpJson::RequestError.new("malformed:#{arg_name}:#{msg}:")
  end

end
