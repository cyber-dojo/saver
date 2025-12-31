
def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 333 ],
    [ 'total_time',    '<=', 100 ],
    [ nil ],
    [ 'failure_count', '<=', 0   ],
    [ 'error_count'  , '<=', 0   ],
    [ 'skip_count'   , '<=', 0   ],
  ]
end
