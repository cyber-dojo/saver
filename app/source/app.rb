# frozen_string_literal: true
require_relative 'app_base'

class App < AppBase

  def initialize(externals)
    super(externals)
  end

  get_json(:prober, :sha)
  get_json(:prober, :alive?)
  get_json(:prober, :ready?)

  # - - - - - - - - - - - - - - - - -

  put_json(:model, :group_create)
  get_json(:model, :group_exists?)
  get_json(:model, :group_manifest)
  put_json(:model, :group_join)
  get_json(:model, :group_joined)

  put_json(:model, :kata_create)
  get_json(:model, :kata_exists?)
  get_json(:model, :kata_manifest)
  get_json(:model, :kata_events)
  get_json(:model, :kata_event)
  get_json(:model, :katas_events)

  put_json(:model, :kata_ran_tests)
  put_json(:model, :kata_predicted_right)
  put_json(:model, :kata_predicted_wrong)
  put_json(:model, :kata_reverted)
  put_json(:model, :kata_checked_out)

  get_json(:model, :kata_option_get)
  put_json(:model, :kata_option_set)

  # - - - - - - - - - - - - - - - - -
  # disk methods: Deprecated

  post_json(:disk, :assert)
  post_json(:disk, :run)
  post_json(:disk, :assert_all)
  post_json(:disk, :run_all)
  post_json(:disk, :run_until_true)
  post_json(:disk, :run_until_false)

end
