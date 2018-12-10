#!/bin/bash
set -e

if [[ ! -d /cyber-dojo/groups ]]; then
  mkdir -p /cyber-dojo/groups
fi
if [[ ! -d /cyber-dojo/katas ]]; then
  mkdir -p /cyber-dojo/katas
fi

# The --host is needed for IPv4 and IPv6 addresses
bundle exec rackup \
  --warn \
  --host 0.0.0.0 \
  --port 4537 \
  --server thin \
  --env production \
    config.ru
