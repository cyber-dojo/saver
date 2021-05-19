#!/bin/bash -Eeu

merkely_fingerprint()
{
  echo "docker://$(server_image):$(image_tag)"
}

