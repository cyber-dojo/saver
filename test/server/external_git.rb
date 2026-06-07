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

end
