
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2500 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 14   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1500 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 215  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
