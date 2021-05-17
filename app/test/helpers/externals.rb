# frozen_string_literal: true
require_relative '../external/custom_start_points'
require_relative '../require_source'
require_source 'externals'

module TestHelpersExternals

  def externals
    @externals ||= Externals.new
  end

  def disk
    externals.disk
  end

  def model
    externals.model
  end

  def prober
    externals.prober
  end

  def random
    externals.random
  end

  def time
    externals.time
  end

  # - - - - - - - - - - - - - - - - -

  def custom_manifest
    @display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(@display_name)
    manifest['version'] = version
    manifest
  end

  def custom_start_points
    External::CustomStartPoints.new
  end

end
