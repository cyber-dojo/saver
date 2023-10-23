
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
export -f root_dir
