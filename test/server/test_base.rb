require_relative 'id58_test_base'
require_relative 'capture_stdout_stderr'
require_relative 'data/kata_test_data'
require_relative 'doubles/disk_fake'
require_relative 'doubles/random_stub'
require_relative 'doubles/time_stub'
require_relative 'helpers/disk'
require_relative 'helpers/externals'
require_relative 'helpers/model'
require_relative 'helpers/rack'
require_relative 'require_source'
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

  def self.disk_tests(id58_suffix, *lines, &block)
    test(id58_suffix, ['<disk:Real>'] + lines) do
      instance_exec(&block)
    end
    test(id58_suffix, ['<disk:Fake>'] + lines) do
      externals.instance_variable_set('@disk', DiskFake.new)
      instance_eval(&block)
    end
  end

  def self.versions_test(id58_suffix, *lines, &block)
    versions = (0..Model::CURRENT_VERSION)
    versions.each do |version|
      version_test(version, id58_suffix, *lines, &block)
    end
  end

  def self.versions3_test(id58_suffix, *lines, &block)
    versions = (0..2)
    versions.each do |version|
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
    yield(id, kata_event(id, -1)['files'])
  end

  def assert_v2_last_commit_message(id, expected)
    return unless version == 2

    dir = "/#{disk.root_dir}/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}"
    stdout = shell.assert_cd_exec(dir, 'git log --abbrev-commit --pretty=oneline')
    last = stdout.lines[0]
    diagnostic = "\nexpected:#{expected}\n  actual:#{last}"
    assert last.include?(expected), diagnostic
  end
end
