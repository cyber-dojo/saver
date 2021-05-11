# frozen_string_literal: true
require_relative 'external/custom_start_points'
require_relative 'external/http'
require_relative 'external/saver'

class Externals

  def custom_start_points
    @custom_start_points ||= External::CustomStartPoints.new
  end

  def saver
    @saver ||= External::Saver.new(http)
  end

  def http
    @http ||= External::Http.new
  end

end
