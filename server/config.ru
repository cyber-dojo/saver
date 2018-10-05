require_relative 'src/prometheus/collector'
require_relative 'src/prometheus/exporter'
require_relative 'src/externals'
require_relative 'src/rack_dispatcher'
require 'rack'

use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

externals = Externals.new
run RackDispatcher.new(externals.grouper, Rack::Request)
