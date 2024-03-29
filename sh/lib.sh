
repo_root()
{
  git rev-parse --show-toplevel
}
export -f repo_root

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
    cat "$(repo_root)/tmp/coverage/server/coverage.json"
    echo ', "client":'
    cat "$(repo_root)/tmp/coverage/client/coverage.json"
    echo '}'
  } > "$(coverage_json_path)"
}
export -f write_coverage_json

# - - - - - - - - - - - - - - - - - - -
coverage_json_path()
{
  echo "$(repo_root)/tmp/evidence.json"
}
export -f coverage_json_path
