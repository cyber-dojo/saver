require_relative 'test_base'

class KataEventsTest < TestBase

  def self.id58_prefix
    'D9w'
  end

  version_test 0, 'f5S', %w(
  | already existing kata_events() summary {test-data copied into saver}
  | is "polyfilled" to make it look like version=1
  ) do
    id = '5rTJv5'
    manifest = kata_manifest(id)
    assert_equal 0, manifest['version'], :version
    actual = kata_events(id)
    t0 = [2019,1,16,12,44,55,800239]
    t1 = [2019,1,16,12,45,40,544806]
    t2 = [2019,1,16,12,45,46,82887]
    t3 = [2019,1,16,12,45,52,220587]
    expected = [
      { 'index' => 0, 'major_index' => 0, 'minor_index' => 0, 'colour' => 'create', 'time' => t0, 'event' => 'created' },
      { 'index' => 1, 'major_index' => 1, 'minor_index' => 0, 'colour' => 'red',    'time' => t1, 'duration' => 1.46448,  'predicted' => 'red' },
      { 'index' => 2, 'major_index' => 2, 'minor_index' => 0, 'colour' => 'amber',  'time' => t2, 'duration' => 1.031421, 'predicted' => 'none' },
      { 'index' => 3, 'major_index' => 3, 'minor_index' => 0, 'colour' => 'green',  'time' => t3, 'duration' => 1.042027, 'predicted' => 'none' },
    ]
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - -

  version_test 1, 'rp8', %w(
  | already existing kata_events() summary {test-data copied into saver}
  ) do
    id = '5U2J18'
    assert_equal 1, kata_manifest(id)['version'], :version
    actual = kata_events(id)
    t0 = [2020,10,19,12,52,46,396907]
    t1 = [2020,10,19,12,52,54,772809]
    t2 = [2020,10,19,12,52,58,547002]
    t3 = [2020,10,19,12,53,3,256202]
    d1 = 0.491393
    d2 = 0.426736
    d3 = 0.438522
    expected = [
      { 'index' => 0, 'major_index' => 0, 'minor_index' => 0, 'colour' => 'create', 'time' => t0, 'event' => 'created' },
      { 'index' => 1, 'major_index' => 1, 'minor_index' => 0, 'colour' => 'red',    'time' => t1, 'duration' => d1, 'predicted' => 'none' },
      { 'index' => 2, 'major_index' => 2, 'minor_index' => 0, 'colour' => 'amber',  'time' => t2, 'duration' => d2, 'predicted' => 'none' },
      { 'index' => 3, 'major_index' => 3, 'minor_index' => 0, 'colour' => 'green',  'time' => t3, 'duration' => d3, 'predicted' => 'none' }
    ]
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'ds0', %w( 
  | kata_events v2 
  ) do
    stdout = { 'content' => 'so', 'truncated' => false }
    stderr = { 'content' => 'se', 'truncated' => true }
    summary = { 'colour' => 'red' }
    t0 = [2021,6,12, 6,9,51,899055]
    t1 = [2021,6,12, 6,57,895675]
    t2 = [2021,6,12, 7,12,685675]
    t3 = [2021,6,12, 7,48,673675]
    t4 = [2021,6,12, 7,59,367523]
    t5 = [2021,6,12, 8,13,367523]
    t6 = [2021,6,12, 9,34,675236]
    externals.instance_exec { @time = TimeStub.new(t0, t1, t2, t3, t4, t5, t6) }

    in_kata do |id|
      files = kata_event(id, 0)['files']
      
      kata_file_create(id, 1, files, 'newfile.txt')
      
      kata_ran_tests(id, 2, files, stdout, stderr,   '0', summary)

      files['newfile.txt'] = { 'content' => 'edited' }
      kata_file_rename(id, 3, files, 'newfile.txt', 'newfile2.txt')

      kata_ran_tests(id, 5, files, stdout, stderr,   '0', summary)
      
      kata_ran_tests(id, 6, files, stdout, stderr, '137', summary)

      actual = kata_events(id)
      assert_equal 7, actual.size

      assert_equal kata_create_event(0, t0), actual[0], 0
      assert_equal file_create_event(1, 0, 1, t1, 'newfile.txt'), actual[1], 1
      assert_equal rag_event(2, 1, 0, t2, 'red', 0, 0), actual[2], 2
      assert_equal file_edit_event(3, 1, 1, t3, 'newfile.txt', 1, 0), actual[3], 3
      assert_equal file_rename_event(4, 1, 2, t4, 'newfile.txt', 'newfile2.txt'), actual[4], 4
      assert_equal rag_event(5, 2, 0, t5, 'red', 0, 0), actual[5], 5
      assert_equal rag_event(6, 3, 0, t6, 'red', 0, 0), actual[6], 6
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  versions_test 'eh4', %w( 
  | polyfill creation event with
  | diff_added_count=0
  | diff_deleted_count=0
  | colour=create
  ) do
    t0 = [2021,6,12, 6,9,51,899055]
    externals.instance_exec { @time = TimeStub.new(t0) }
    in_kata do |id|
      actual = kata_events(id)
      expected = [{ 
        'index' => 0, 
        'major_index' => 0,
        'minor_index' => 0,
        'colour' => 'create', 
        'time' => t0, 
        'event' => 'created'
      }]
      if @version == 2
        expected[0]['diff_added_count'] = 0
        expected[0]['diff_deleted_count'] = 0
      end
      assert_equal expected, actual
    end
  end

  private

  def kata_create_event(index, time)
    {
      'index' => 0,
      'major_index' => 0,
      'minor_index' => 0,
      'time' => time,
      'colour' => 'create',
      'event' => 'created',
      'diff_added_count' => 0,
      'diff_deleted_count' => 0
    }
  end

  def rag_event(index, major, minor, time, colour, diff_added_count, diff_deleted_count)
    {
      'index' => index,
      'major_index' => major,
      'minor_index' => minor,
      'time' => time,
      'colour' => colour,
      'diff_added_count' => diff_added_count,
      'diff_deleted_count' => diff_deleted_count
    }
  end

  def file_create_event(index, major, minor, time, filename)
    {
      'index' => index,
      'major_index' => major,
      'minor_index' => minor,
      'time' => time,
      'colour' => 'file_create',
      'filename' => filename,
      'diff_added_count' => 0,
      'diff_deleted_count' => 0
    }
  end

  def file_edit_event(index, major, minor, time, filename, diff_added_count, diff_deleted_count)
    {
      'index' => index,
      'major_index' => major,
      'minor_index' => minor,
      'time' => time,
      'colour' => 'file_edit',
      'filename' => filename,
      'diff_added_count' => diff_added_count,
      'diff_deleted_count' => diff_deleted_count
    }
  end

  def file_rename_event(index, major, minor, time, old_filename, new_filename)
    {
      'index' => index,
      'major_index' => major,
      'minor_index' => minor,
      'time' => time,
      'colour' => 'file_rename',
      'old_filename' => old_filename,
      'new_filename' => new_filename,
      'diff_added_count' => 0,
      'diff_deleted_count' => 0
    }
  end

end
