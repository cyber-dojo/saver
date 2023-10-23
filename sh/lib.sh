
# - - - - - - - - - - - - - - - - - - -
root_dir()
{
  git rev-parse --show-toplevel
}
export -f root_dir

# - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}
export -f on_ci

# - - - - - - - - - - - - - - - - - - -
write_coverage_json()
{
  {
    echo '{ "server":'
    cat "$(root_dir)/tmp/coverage/server/coverage.json"
    echo ', "client":'
    cat "$(root_dir)/tmp/coverage/client/coverage.json"
    echo '}'
  } > "$(coverage_json_path)"
}
export -f write_coverage_json

# - - - - - - - - - - - - - - - - - - -
coverage_json_path()
{
  echo "$(root_dir)/tmp/evidence.json"
}
export -f coverage_json_path
