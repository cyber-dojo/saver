
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 1957 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 12   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1320 ],
    [ 'code.lines.missed'   , '<=', 10   ],
    [ 'code.branches.total' , '<=', 151  ],
    [ 'code.branches.missed', '<=', 2    ],
  ]
end
