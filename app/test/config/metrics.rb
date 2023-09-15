
# Max code/test metrics values.
# Used by check_test_metrics.rb
# which is called from run.sh

MAX = {
  failures:0,
  errors:0,
  warnings:0,
  skips:0,

  duration:100,

  test: {
    lines: {
       total:1756,
      missed:0,
    },
    branches: {
       total:12,
      missed:0,
    }
  },

  code: {
    lines: {
       total:1243,
      missed:10,
    },
    branches: {
       total:139,
      missed:2,
    }
  }
}
