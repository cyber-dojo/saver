require_relative 'id58_test_base'
require_relative 'capture_stdout_stderr'
require_relative 'data/kata_test_data'
require_relative 'doubles/random_stub'
require_relative 'doubles/time_stub'
require_relative 'helpers/disk'
require_relative 'helpers/externals'
require_relative 'helpers/model'
require_relative 'helpers/rack'
require_relative 'require_source'
require_source 'no_longer_implemented_error'
require 'json'

class TestBase < Id58TestBase

  include CaptureStdoutStderr
  include KataTestData
  include TestHelpersDisk
  include TestHelpersExternals
  include TestHelpersModel
  include TestHelpersRack

  def in_group(&block)
    yield group_create(custom_manifest)
  end

  # Creates a minimal 2-LTF Tennis cluster and returns its id.
  def two_ltf_cluster
    cluster_create([
      manifest_Tennis_refactoring_Python_unitttest,
      manifest_Tennis_refactoring_Ruby_minitest ])
  end

  def in_kata(gid = nil, &block)
    if gid.nil?
      yield kata_create(custom_manifest)
    else
      yield group_join(gid)
    end
  end

  def custom_manifest
    manifest = manifest_Tennis_refactoring_Python_unitttest
    manifest['version'] = version
    manifest
  end

  def self.versions_test(id58_suffix, *lines, &block)
    versions = (0..Model::CURRENT_VERSION)
    versions.each do |version|
      version_test(version, id58_suffix, *lines, &block)
    end
  end

  def self.versions_01_test(id58_suffix, *lines, &block)
    (0..1).each do |version|
      version_test(version, id58_suffix, *lines, &block)
    end
  end

  def self.version_test(version, id58_suffix, *lines, &block)
    lines.unshift("<version:#{version}>")
    test(id58_suffix, *lines) do
      @version = version
      instance_exec(&block)
    end
  end

  attr_reader :version

  def in_tennis_kata
    id = kata_create(manifest_Tennis_refactoring_Python_unitttest)
    # filenames = ["cyber-dojo.sh", "readme.txt", "tennis.py", "tennis_unit_test.py"]    
    stdout = { 'content' => 'some-stdout', 'truncated' => false }
    stderr = { 'content' => 'some-stderr', 'truncated' => false }
    status = '0'
    yield(id, kata_event(id, 0)['files'], stdout, stderr, status)
  end

  def assert_tag_commit_message(id, tag, expected)
    dir = "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}"
    stdout = shell.assert_cd_exec(dir, "git tag --list --format='%(contents)' #{tag}")
    line = stdout.lines[0]
    diagnostic = "\nexpected:#{expected}\n  actual:#{line}"
    assert line.include?(expected), diagnostic
  end

  # Absolute path of a file in a kata's working tree, e.g.
  # /cyber-dojo/katas/Sy/G9/sT/events.json
  def working_tree_path(id, filename)
    "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/#{filename}"
  end
end
