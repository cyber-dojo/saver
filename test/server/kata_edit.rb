require_relative 'test_base'

class KataEditTest < TestBase

  def initialize(arg)
    super(arg)
    @version = 2
  end

  def self.id58_prefix
    'Dcc'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A50', %w(
  |kata_switch_file results in a switch-file event 
  |when the incoming files are identical to the existing most-recent files
  |and filename is the name of the (unedited) switched-to file
  ) do
    in_kata do |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      assert_equal 2, manifest['version']

      events = kata_events(id)
      assert_equal 1, events.size
      event0 = events[-1]
      assert_equal 0, event0['index']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']

      kata_switch_file(id, index=2, files, 'readme.txt') # <<<<<<<
      events = kata_events(id)
      assert_equal 3, events.size
      event2 = events[-1]
      assert_equal 2, event2['index']      
      assert_equal 'switch-file', event2['colour']
      assert_equal 'readme.txt', event2['filename']
      assert_v2_last_commit_message(id, '2 switched to file readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A51', %w(
  |kata_switch_file results in an edit-file event 
  |when one file in the incoming files has been edited
  |and filename is the name of the edited file we just switched from
  ) do
    in_kata do |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      assert_equal 2, manifest['version']

      events = kata_events(id)
      assert_equal 1, events.size
      event0 = events[-1]
      assert_equal 0, event0['index']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']

      files['readme.txt']['content'] += 'Hello world'

      kata_switch_file(id, index=2, files, 'test_hiker.sh') # <<<<<<<
      events = kata_events(id)
      assert_equal 3, events.size
      event2 = events[-1]
      assert_equal 2, event2['index']
      assert_equal 'edit-file', event2['colour']
      assert_equal 'readme.txt', event2['filename']
      assert_v2_last_commit_message(id, '2 edited file readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A52', %w(
  |kata_create_file results in a create-file event
  |and the created file has empty content
  ) do
    in_kata do |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      assert_equal 2, manifest['version']

      events = kata_events(id)
      assert_equal 1, events.size
      event0 = events[-1]
      assert_equal 0, event0['index']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']

      kata_create_file(id, index=2, 'wibble.py') # <<<<<<<
      events = kata_events(id)
      assert_equal 3, events.size
      event2 = events[-1]
      assert_equal 2, event2['index']
      assert_equal 'create-file', event2['colour']
      assert_equal 'wibble.py', event2['filename']

      files = kata_event(id, -1)['files']
      filenames = files.keys
      assert filenames.include?('wibble.py')
      assert_equal '', files['wibble.py']['content']
      assert_v2_last_commit_message(id, '2 created file wibble.py')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A53', %w(
  |kata_delete_file results in a delete-file event 
  ) do
    in_kata do |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      assert_equal 2, manifest['version']

      events = kata_events(id)
      assert_equal 1, events.size
      event0 = events[-1]
      assert_equal 0, event0['index']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']

      kata_delete_file(id, index=2, 'readme.txt') # <<<<<<<
      events = kata_events(id)
      assert_equal 3, events.size
      event2 = events[-1]
      assert_equal 2, event2['index']
      assert_equal 'delete-file', event2['colour']
      assert_equal 'readme.txt', event2['filename']

      files = kata_event(id, -1)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
      assert_v2_last_commit_message(id, '2 deleted file readme.txt')
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A54', %w(
  |kata_rename_file results in a rename-file event 
  ) do
    in_kata do |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      assert_equal 2, manifest['version']

      events = kata_events(id)
      assert_equal 1, events.size
      event0 = events[-1]
      assert_equal 0, event0['index']

      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      event1 = events[-1]
      assert_equal 1, event1['index']

      content = files['readme.txt']['content']
      kata_rename_file(id, index=2, 'readme.txt', 'readme.md') # <<<<<<<
      events = kata_events(id)
      assert_equal 3, events.size
      event2 = events[-1]
      assert_equal 2, event2['index']
      assert_equal 'rename-file', event2['colour']
      assert_equal 'readme.txt', event2['old_filename']
      assert_equal 'readme.md', event2['new_filename']

      files = kata_event(id, -1)['files']
      filenames = files.keys
      refute filenames.include?('readme.txt')
      assert filenames.include?('readme.md')
      assert_equal content, files['readme.md']['content']
      assert_v2_last_commit_message(id, '2 renamed file readme.txt to readme.md')
    end
  end

  private

  def in_kata
    id = kata_create(manifest_Tennis_refactoring_Python_unitttest)
    data = bats
    yield(id, data['files'], data['stdout'], data['stderr'], data['status'])    
  end
end
