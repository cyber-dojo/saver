# frozen_string_literal: true
require_relative 'app_base'

class App < AppBase

  def initialize(externals)
    super(externals)
  end

  get_json(:sha,    'prober')
  get_json(:alive?, 'prober')
  get_json(:ready?, 'prober')

  post_json(:assert,          'disk')
  post_json(:run,             'disk')
  post_json(:assert_all,      'disk')
  post_json(:run_all,         'disk')
  post_json(:run_until_true,  'disk')
  post_json(:run_until_false, 'disk')

end
