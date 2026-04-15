
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2351 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 14   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1393 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 163  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
