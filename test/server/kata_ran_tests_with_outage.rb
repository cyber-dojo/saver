require_relative 'test_base'

class KataRanTestsWithOutageTest < TestBase

  version_test 2, 'Dace4A', %w(
  | when there is a saver outage
  | the incoming files do NOT contain a filename that WAS in the previous event
  | but the intermediate file-event to record the file-delete/rename was MISSED
  | (due to a saver outage)
  | then saver handles this.
  ) do
    # Note that the same situation occurs in v2 katas that were created 
    # before file-events became live.

    in_kata do |id|
      files = kata_event(id, 0)['files']
      stdout = bats['stdout']
      stderr = bats['stderr']
      status = bats['status']

      files.delete('readme.txt')

      kata_ran_tests(id, files, stdout, stderr, status, red_summary)
      events = kata_events(id)
      assert_equal 2, events.size
      light = events[1]
      assert_equal 'red', light['colour']
      assert_equal 1, light['major_index']
      assert_equal 0, light['minor_index']
    end
  end
end
