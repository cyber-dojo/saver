
def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 314 ],
    [ 'total_time',    '<=',  50 ],
    [ nil ],
    [ 'failure_count', '<=', 0   ],
    [ 'error_count'  , '<=', 0   ],
    [ 'skip_count'   , '<=', 0   ],
  ]
end
