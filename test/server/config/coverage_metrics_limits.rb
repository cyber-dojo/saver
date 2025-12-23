
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 1978 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 12   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1297 ],
    [ 'code.lines.missed'   , '<=', 10   ],
    [ 'code.branches.total' , '<=', 147  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
