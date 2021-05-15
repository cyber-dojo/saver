
# max values used by cyberdojo/check-test-results image
# which is called from scripts/run_tests_in_containers.sh

MAX = {
  failures:0,
  errors:0,
  warnings:0,
  skips:0,

  duration:10,

  app: {
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
