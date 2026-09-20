require_relative 'test_base'

class ExternalGitTest < TestBase

  version_test 2, 'Eg1TnF', %w(
  | External::Git#tag_tree_blobs raises TagNotFound when refs/tags/<index> is
  | absent. git_archive's retry is built on this raise, and Sp4DkD/F drive that
  | retry with a stubbed @git; this covers the real raise directly.
  ) do
    in_kata do |id|
      dir = "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}"
      assert_raises(External::Git::TagNotFound) do
        git.tag_tree_blobs(dir, 9999)
      end
    end
  end

  version_test 2, 'Eg1TnG', %w(
  | External::Git#advance_main raises RefAdvanceFailed when refs/heads/main does
  | not point at the base_oid it is given, and leaves the ref where it was.
  | That compare-and-swap is how a save detects a concurrent winner, so a losing
  | advance must not move main onto the loser's commit.
  ) do
    in_kata do |id|
      dir = "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}"
      built = git.commit_options(dir, 'built on the current head') { |_options| {} }
      # A well-formed OID that main cannot be pointing at, so the swap loses.
      absent_oid = '0' * 40

      assert_raises(External::Git::RefAdvanceFailed) do
        git.advance_main(dir, built[:new_oid], absent_oid)
      end

      # commit_options reads HEAD, so its base_oid is where main points now.
      still_at = git.commit_options(dir, 'reads where main points') { |_options| {} }
      assert_equal built[:base_oid], still_at[:base_oid]
    end
  end

end
