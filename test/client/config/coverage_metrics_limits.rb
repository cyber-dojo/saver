
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 590 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 2   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 127 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 2   ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end