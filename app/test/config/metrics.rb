
# Max code/test metrics values.
# Used by check_test_metrics.rb
# Called from run.sh

MAX = {
  failures:0,
  errors:0,
  warnings:0,
  skips:0,

  duration:5,

  test: {
    lines: {
       total:1565,
      missed:0,
    },
    branches: {
       total:0,
      missed:0,
    }
  },

  code: {
    lines: {
       total:963,
      missed:0,
    },
    branches: {
       total:108,
      missed:0,
    }
  }
}
