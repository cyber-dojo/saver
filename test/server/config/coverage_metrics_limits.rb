
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 1966 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 12   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1313 ],
    [ 'code.lines.missed'   , '<=', 11   ],
    [ 'code.branches.total' , '<=', 153  ],
    [ 'code.branches.missed', '<=', 3    ],
  ]
end
