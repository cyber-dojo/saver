
def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 311 ],
    [ 'total_time',    '<=', 100 ],
    [ nil ],
    [ 'failure_count', '<=', 0   ],
    [ 'error_count'  , '<=', 0   ],
    [ 'skip_count'   , '<=', 0   ],
  ]
end
