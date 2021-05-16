#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  echo Removing old images
  local -r dils=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_latest "${dils}" "$(server_image)"
  remove_all_but_latest "${dils}" "$(client_image)"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r dils="${1}"
  local -r name="${2}"
  for image_name in `echo "${dils}" | grep "${name}:"`
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      if [ "${image_name}" != "${name}:$(image_tag)" ]; then
        if [ "${image_name}" != "${name}:<none>" ]; then
          docker image rm "${image_name}"
        fi
      fi
    fi
  done
}
