#!/bin/bash
set -e

# Note that the --host is needed for IPv4 and IPv6 addresses

rackup \
  --warn \
  --host 0.0.0.0 \
  --port 4538 \
  --server thin \
  --env production \
    /app/config/config.ru
