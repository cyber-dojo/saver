#!/bin/bash -Eeu

tag_images_to_latest()
{
  docker tag "$(server_image):$(image_tag)" "$(server_image):latest"
  docker tag "$(client_image):$(image_tag)" "$(client_image):latest"
}


