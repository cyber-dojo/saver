
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
       total:200,
      missed:0,
    },
    branches: {
       total:2,
      missed:0,
    }
  },

  test: {
    lines: {
       total:1400,
      missed:0,
    },
    branches: {
       total:6,
      missed:0,
    }
  }
}
