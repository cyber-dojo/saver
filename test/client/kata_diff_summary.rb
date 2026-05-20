require_relative 'test_base'

class KataDiffSummaryTest < TestBase

  version_test 2, 'K3xPwR', %w(
  | v2 kata: diff_summary when cyber-dojo.sh has 2 lines added
  | returns changed entry with correct line counts
  | and unchanged entries for the other 3 files
  ) do
    in_tennis_kata do |id, files|
      original_content = files['cyber-dojo.sh']['content']
      files['cyber-dojo.sh']['content'] = original_content + "Hello\nWorld\n"
      kata_file_edit(id, 1, files)

      result = diff_summary(id, 0, 1)

      sh = result.find { |d| d['new_filename'] == 'cyber-dojo.sh' }
      assert_equal 'changed', sh['type']
      assert_equal 'cyber-dojo.sh', sh['old_filename']
      assert_equal({ 'added' => 2, 'deleted' => 0, 'same' => 1 }, sh['line_counts'])
      assert_nil sh['lines']

      unchanged = result.select { |d| d['type'] == 'unchanged' }
      assert_equal 3, unchanged.count
    end
  end

end
