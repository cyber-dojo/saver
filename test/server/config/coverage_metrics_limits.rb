
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2378 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 18   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1410 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 167  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
