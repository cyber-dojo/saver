require_relative 'id58_test_base'
require_relative 'capture_stdout_stderr'
require_relative 'kata_test_data'
require_source 'externals'

class TestBase < Id58TestBase

  include CaptureStdoutStderr
  include KataTestData

  def initialize(arg)
    super(arg)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def externals
    @externals ||= Externals.new
  end

  def saver
    externals.saver
  end

  # - - - - - - - - - - - - - - - - - -

  def group_create(manifest)
    saver.group_create(manifest)
  end

  def group_exists?(id)
    saver.group_exists?(id)
  end

  def group_manifest(id)
    saver.group_manifest(id)
  end

  def group_join(id, indexes=(0..63).to_a.shuffle)
    saver.group_join(id, indexes)
  end

  def group_joined(id)
    saver.group_joined(id)
  end

  def group_fork(id, index)
    saver.group_fork(id, index)
  end

  # - - - - - - - - - - - - - - - - - -

  def kata_create(manifest)
    saver.kata_create(manifest)
  end

  def kata_exists?(id)
    saver.kata_exists?(id)
  end

  def kata_manifest(id)
    saver.kata_manifest(id)
  end

  def kata_events(id)
    saver.kata_events(id)
  end

  def kata_event(id, index)
    saver.kata_event(id, index)
  end

  def katas_events(ids, indexes)
    saver.katas_events(ids, indexes)
  end

  # - - - - - - - - - - - - - - - - - -

  # An arbitrary well-formed laptop_id (SecureRandom.hex(32) format), passed
  # explicitly by tests on every event-write as a real client now does. Its
  # specific value is not significant.
  def laptop_id
    'd4f9a0c71e2b85630af1c9e4b7028d5f6a3c1e8092b4d7f60a5e3c19b8d24f70'
  end

  # A second well-formed laptop_id, distinct from laptop_id, for tests that need
  # two different laptops (genuine mobbing).
  def another_laptop_id
    'ca990e850c196480e16b8f04a611297e12ea64c93766055643e0e60f8f8d51e0'
  end

  def kata_file_create(id, index, files, filename, laptop_id)
    saver.kata_file_create(id, index, files, filename, laptop_id)
  end

  def kata_file_delete(id, index, files, filename, laptop_id)
    saver.kata_file_delete(id, index, files, filename, laptop_id)
  end

  def kata_file_rename(id, index, files, old_filename, new_filename, laptop_id)
    saver.kata_file_rename(id, index, files, old_filename, new_filename, laptop_id)
  end

  def kata_file_edit(id, index, files, laptop_id)
    saver.kata_file_edit(id, index, files, laptop_id)
  end

  # - - - - - - - - - - - - - - - - - -

  def kata_option_get(name)
    saver.kata_option_get(id, name)
  end

  def kata_option_set(name, value)
    saver.kata_option_set(id, name, value)
  end

  def kata_fork(id, index)
    saver.kata_fork(id, index)
  end

  def diff_lines(id, was_index, now_index)
    saver.diff_lines(id, was_index, now_index)
  end

  def diff_summary(id, was_index, now_index)
    saver.diff_summary(id, was_index, now_index)
  end

  # - - - - - - - - - - - - - - - - - -

  def self.versions_test(id58_suffix, *lines, &block)
    current_version = 2
    versions = (0..current_version)
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
    test(id58_suffix, *lines, version) do
      self.instance_eval(&block)
    end
  end

  def in_group
    yield group_create(custom_manifest)
  end

  def in_kata
    yield kata_create(custom_manifest)
  end

  def in_tennis_kata
    id = kata_create(custom_manifest)
    yield(id, kata_event(id, 0)['files'])
  end

  def custom_manifest
    manifest = manifest_Tennis_refactoring_Python_unitttest
    manifest['version'] = version
    manifest
  end

  # - - - - - - - - - - - - - - - - - -

  def two_timed(n, algos)
    t0,t1 = 0,0
    n.times do
      # which one to do first?
      if rand(42) % 2 == 0
        t0 += timed { algos[0].call }
        t1 += timed { algos[1].call }
      else
        t1 += timed { algos[1].call }
        t0 += timed { algos[0].call }
      end
    end
    [t0,t1]
  end

  def timed
    started_at = clock_time
    yield
    finished_at = clock_time
    (finished_at - started_at)
  end

  def clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

end
