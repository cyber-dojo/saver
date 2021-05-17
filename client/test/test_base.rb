# frozen_string_literal: true
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
    @exernals ||= Externals.new
  end

  def custom_start_points
    externals.custom_start_points
  end

  def custom_manifest
    display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    manifest
  end

  def saver
    externals.saver
  end

  def default_options
    {}
  end

  # - - - - - - - - - - - - - - - - - -

  def group_create(manifest, options)
    saver.group_create([manifest], options)
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

  # - - - - - - - - - - - - - - - - - -

  def kata_create(manifest, options)
    saver.kata_create(manifest, options)
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

  def kata_option_get(name)
    saver.kata_option_get(id, name)
  end

  def kata_option_set(name, value)
    saver.kata_option_set(id, name, value)
  end

  # - - - - - - - - - - - - - - - - - -

  def self.version_tests(versions, id58_suffix, *lines, &block)
    versions.each do |version|
      test(id58_suffix + version.to_s, *lines) do
        @version = version
        self.instance_eval(&block)
      end
    end
  end

  def version
    @version
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
