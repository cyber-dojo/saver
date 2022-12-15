#!/usr/bin/env bash
set -Eeu

kosli_fingerprint()
{
  echo "docker://$(server_image):$(image_tag)"
}

