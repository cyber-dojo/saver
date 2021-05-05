# frozen_string_literal: true
require_relative 'app_base'

class App < AppBase

  def initialize(externals)
    super(externals)
  end

  get_json(:prober, :sha)
  get_json(:prober, :alive?)
  get_json(:prober, :ready?)

  post_json(:disk, :assert)
  post_json(:disk, :run)
  post_json(:disk, :assert_all)
  post_json(:disk, :run_all)
  post_json(:disk, :run_until_true)
  post_json(:disk, :run_until_false)

end
