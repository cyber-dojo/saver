require_relative 'app_base'

class App < AppBase

  def initialize(externals)
    super(externals)
  end

   get_json(:prober, :sha)
   get_json(:prober, :alive?)
   get_json(:prober, :ready?)

  # - - - - - - - - - - - - - - - - -

  post_json(:model, :group_create2)
  post_json(:model, :group_create_custom)
  post_json(:model, :group_create)
   get_json(:model, :group_exists?)
   get_json(:model, :group_manifest)
  post_json(:model, :group_join)
   get_json(:model, :group_joined)
  post_json(:model, :group_fork)

   # - - - - - - - - - - - - - - - - -

  post_json(:model, :kata_create2)
  post_json(:model, :kata_create_custom)
  post_json(:model, :kata_create)
   get_json(:model, :kata_download)
   get_json(:model, :kata_exists?)
   get_json(:model, :kata_events)
   get_json(:model, :kata_event)
   get_json(:model, :kata_manifest)
  post_json(:model, :kata_fork)
   get_json(:model, :katas_events)

  post_json(:model, :kata_ran_tests)
  post_json(:model, :kata_predicted_right)
  post_json(:model, :kata_predicted_wrong)
  post_json(:model, :kata_reverted)
  post_json(:model, :kata_checked_out)

   get_json(:model, :kata_option_get)
  post_json(:model, :kata_option_set)

end
