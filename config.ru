$stdout.sync = true
$stderr.sync = true

require_relative 'src/externals'
require_relative 'src/rack_dispatcher'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'rack'

use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

externals = Externals.new
run RackDispatcher.new(externals, Rack::Request)
