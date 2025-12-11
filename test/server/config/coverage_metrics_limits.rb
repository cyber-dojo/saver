
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 1930 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 12   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1299 ],
    [ 'code.lines.missed'   , '<=', 10   ],
    [ 'code.branches.total' , '<=', 145  ],
    [ 'code.branches.missed', '<=', 2    ],
  ]
end
