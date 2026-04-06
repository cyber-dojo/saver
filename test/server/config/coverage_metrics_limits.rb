
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2314 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 14   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1385 ],
    [ 'code.lines.missed'   , '<=', 4    ],
    [ 'code.branches.total' , '<=', 163  ],
    [ 'code.branches.missed', '<=', 1    ],
  ]
end
