
def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 133 ],
    [ 'total_time',    '<=', 30  ],
    [ nil ],
    [ 'failure_count', '<=', 0   ],
    [ 'error_count'  , '<=', 0   ],
    [ 'skip_count'   , '<=', 0   ],
  ]
end
