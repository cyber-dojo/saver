
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2456 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 24   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1315 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 161  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
