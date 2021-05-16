#!/bin/bash -Eeu

# The cyberdojo/versioner refresh-env.sh script
# https://github.com/cyber-dojo/versioner/blob/master/sh/refresh-env.sh
# relies on being able to:
#   - get the :latest image
#   - extract the SHA env-var embedded inside it
#   - use the 1st 7 chars of the SHA as a latets-equivalent tag
#
# Removing old images and not busting the image layer
# cache requires the latest image is tagged to :latest

tag_images_to_latest()
{
  docker tag "$(server_image):$(image_tag)" "$(server_image):latest"
  docker tag "$(client_image):$(image_tag)" "$(client_image):latest"
}


