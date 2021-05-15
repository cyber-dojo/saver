#!/bin/bash -Eeu

#- - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_show_help()
{
  local -r MY_NAME=./test.sh
  if [ "${1:-}" == '-h' ] || [ "${1:-}" == '--help' ]; then
    echo
    echo "Use: ${MY_NAME} [$(server_name)|$(client_name)] [ID...]"
    echo "Use: ${MY_NAME} -h|--help"
    echo 'Options:'
    echo "   $(server_name)      run the tests from inside the $(server_name) container"
    echo "   $(client_name)      run the tests from inside the $(client_name) container"
    echo '   ID...       only run the tests matching these identifiers'
    echo '   -h|--help   show this help'
    echo "               no options will run all $(server_name) tests, then all $(client_name) tests"
    echo
    exit 0
  fi
}
