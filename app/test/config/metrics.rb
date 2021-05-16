
# Max code/test metrics values.
# Used by check_test_metrics.rb
# Called from run.sh

MAX = {
  failures:0,
  errors:0,
  warnings:0,
  skips:0,

  duration:10,

  code: {
    lines: {
       total:900,
      missed:0,
    },
    branches: {
       total:125,
      missed:4,
    }
  },

  test: {
    lines: {
       total:1700,
      missed:0,
    },
    branches: {
       total:12,
      missed:0,
    }
  }
}