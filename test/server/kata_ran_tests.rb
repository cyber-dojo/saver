# frozen_string_literal: true

require_relative 'test_base'

class KataRanTestsTest < TestBase
  def self.id58_prefix
    'Sp4'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk1', %w[kata_ran_tests gives same results in all versions] do
    in_kata { |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      assert_tag_commit_message(id, 1, '1 ran tests, no prediction, got red')
      [index, red_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk2', %w[kata_predicted_right gives same results in all versions] do
    in_kata { |id, files, stdout, stderr, status|
      summary = red_summary.merge({ 'predicted' => 'red' })
      kata_predicted_right(id, index=1, files, stdout, stderr, status, summary)
      assert_tag_commit_message(id, 1, '1 ran tests, predicted red, got red')
      [index, summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk3', %w[kata_predicted_wrong gives same results in all versions] do
    in_kata { |id, files, stdout, stderr, status|
      summary = red_summary.merge({ 'predicted' => 'green' })
      kata_predicted_wrong(id, index=1, files, stdout, stderr, status, summary)
      assert_tag_commit_message(id, 1, '1 ran tests, predicted green, got red')
      [index, summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk6', %w[kata_reverted gives same results in all versions] do
    in_kata { |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      kata_ran_tests(id, index=2, files, stdout, stderr, status, red_summary)
      reverted_summary = { 'colour' => 'red', 'revert' => [id, index=1] }
      kata_reverted(id, index=3, files, stdout, stderr, status, reverted_summary)
      expected = JSON.generate({'id': id, 'index': 1})
      assert_tag_commit_message(id, 3, "3 reverted to #{expected}")
      [index, reverted_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk7', %w[kata_checked_out gives same results in all versions] do
    in_kata { |id, files, stdout, stderr, status|
      manifest = kata_manifest(id)
      group_id = manifest["group_id"]
      group_index = manifest["group_index"]
      id2 = group_join(group_id)
      kata_ran_tests(id2, index=1, files, stdout, stderr, status, red_summary)
      checkout = { 'id' => id2, 'index' => 1, 'avatarIndex' => group_index }
      checkout_out_summary = { 'colour' => 'red', 'checkout' => checkout }
      kata_checked_out(id, index=1, files, stdout, stderr, status, checkout_out_summary)
      expected = JSON.generate(checkout)
      assert_tag_commit_message(id, 1, "1 checked out #{expected}")
      [index, checkout_out_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Dk8', %w[
  |kata_ran_tests returns the next index in all versions
  ] do
    in_kata { |id, files, stdout, stderr, status|
      new_index = kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      assert_equal 2, new_index
      [index=1, red_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Dk9', %w[kata_ran_tests with an already used index
  raises "Out of order event" exception] do
    in_kata { |id, files, stdout, stderr, status|
      kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      error = assert_raises(RuntimeError) {
        kata_ran_tests(id, index=1, files, stdout, stderr, status, red_summary)
      }
      assert_equal 'Out of order event', error.message
      [index=1, red_summary]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def in_kata
    manifest = manifest_Tennis_refactoring_Python_unitttest
    manifest['version'] = @version
    gid = group_create(manifest)
    id = group_join(gid)
    index = 1
    data = bats
    files = data['files']
    stdout = data['stdout']
    stderr = data['stderr']
    status = data['status']

    index, summary = *yield(id, files, stdout, stderr, status) # <<<<<<<

    actual = kata_event(id, index)
    assert_equal files, actual['files'], :files
    assert_equal stdout, actual['stdout'], :stdout
    assert_equal stderr, actual['stderr'], :stderr
    assert_equal status, actual['status'], :status
    assert_equal index, actual['index'], :index
    summary.keys.each do |key|
      expected = summary[key]
      assert_equal expected, actual[key], key
    end
  end
end
