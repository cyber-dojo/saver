
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2314 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 14   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1384 ],
    [ 'code.lines.missed'   , '<=', 2    ],
    [ 'code.branches.total' , '<=', 161  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
