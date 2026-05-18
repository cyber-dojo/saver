require_relative 'test_base'
require_source 'model/poly_filler'

class PolyFillerTest < TestBase

  include PolyFiller

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Fq8b1c', %w(
  | polyfill_event copies revert from event_summary into event
  | revert and checkout were added after v0/v1 katas were created
  | so no existing v0/v1 fixture has these keys - tested here
  | via direct call with crafted args
  ) do
    event = {}
    events = [{ 'revert' => { 'index' => 3 } }]
    polyfill_event(event, events, 0)
    assert_equal({ 'index' => 3 }, event['revert'])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Fq8b1d', %w(
  | polyfill_event copies checkout from event_summary into event
  | revert and checkout were added after v0/v1 katas were created
  | so no existing v0/v1 fixture has these keys - tested here
  | via direct call with crafted args
  ) do
    event = {}
    events = [{ 'checkout' => { 'index' => 5 } }]
    polyfill_event(event, events, 0)
    assert_equal({ 'index' => 5 }, event['checkout'])
  end

end
