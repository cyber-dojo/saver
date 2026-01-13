
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2397 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 12   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1402 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 161  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
