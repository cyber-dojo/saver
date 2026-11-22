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

  version_test 2, 'Eg1TnH', %w(
  | every path and every content External::Git returns is UTF-8 text, so a file
  | whose name and content hold non-ASCII letters reads back equal to the UTF-8
  | strings it was written from, through head_blob, tag_tree_blobs, files_blobs
  | and diff alike
  ) do
    in_kata do |id|
      dir = "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}"
      name = 'née ü.txt'
      content = "café\n"
      kata_ran_tests(id, { name => { 'content' => content, 'truncated' => false } },
                     { 'content' => 'this is stdout', 'truncated' => false },
                     { 'content' => 'this is stderr', 'truncated' => false },
                     '0', { 'duration' => 0.457764, 'colour' => 'green', 'predicted' => 'none' })
      added = git.diff(dir, 0, 1).group_by { |file| file[:status] }.fetch(:added)
      expected = {
        head_blob: content,
        tag_tree_blob: content,
        files_blobs: { name => content },
        diff: [[name, [content]]]
      }
      actual = {
        head_blob: git.head_blob(dir, "files/#{name}"),
        tag_tree_blob: git.tag_tree_blobs(dir, 1).fetch("files/#{name}"),
        files_blobs: git.files_blobs(dir, 1),
        diff: added.map { |file| [file[:new_path], file[:lines].map { |line| line[:content] }] }
      }
      assert_equal expected, actual
    end
  end

end
