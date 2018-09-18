require_relative 'src/externals'
require_relative 'src/rack_dispatcher'

externals = Externals.new
run RackDispatcher.new(externals.grouper, Rack::Request)
