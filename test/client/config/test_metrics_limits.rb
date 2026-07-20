
def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 157 ],
    [ 'total_time',    '<=',  10 ],
    [ nil ],
    [ 'failure_count', '<=',   0 ],
    [ 'error_count'  , '<=',   0 ],
    [ 'skip_count'   , '<=',   0 ],
  ]
end
