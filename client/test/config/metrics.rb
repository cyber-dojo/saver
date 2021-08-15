
# Max code/test metrics values.
# Used by check_test_metrics.rb
# which is called from run.sh

MAX = {
  failures:0,
  errors:0,
  warnings:0,
  skips:0,

  duration:10,

  code: {
    lines: {
       total:173,
      missed:0,
    },
    branches: {
       total:2,
      missed:0,
    }
  },

  test: {
    lines: {
       total:647,
      missed:0,
    },
    branches: {
       total:2,
      missed:0,
    }
  }
}
