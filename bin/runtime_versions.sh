#!/usr/bin/env bash
set -Eeu

# What a server runtime is: its Ruby, every gem with every version, and every
# OS package with its version. The one place this is decided, so the two
# runtimes compared are listed alike.
readonly LIST='ruby --version && gem list && apk list --installed | sort'

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} image IMAGE
         ${MY_NAME} container CONTAINER

    Prints a server runtime: its ruby --version, every gem with every
    version (gem list), and every OS package (apk list --installed), of
    IMAGE, or of the running CONTAINER. bin/run_tests_bare.sh saves the
    runtime the server tests ran in, and the workflow compares it with the
    server image's, so the image is attested as unit-tested only when it
    has that same runtime.

    Options:
       -h     Show this help

    Example:
       ${MY_NAME} image cyberdojo/saver:b73cc29

EOF
}

main()
{
  case "${1:-}:${2:-}" in
    -h:* | --help:*)
      show_help
      exit 0
      ;;
    image:?*)
      docker run --rm --entrypoint sh "${2}" -c "${LIST}"
      ;;
    container:?*)
      docker exec "${2}" sh -c "${LIST}"
      ;;
    *)
      show_help
      >&2 echo "ERROR: expected image IMAGE or container CONTAINER"
      exit 42
      ;;
  esac
}

main "$@"
