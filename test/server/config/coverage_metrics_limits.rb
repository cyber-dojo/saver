
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2304 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 14   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1388 ],
    [ 'code.lines.missed'   , '<=', 1    ],
    [ 'code.branches.total' , '<=', 163  ],
    [ 'code.branches.missed', '<=', 1    ],
  ]
end
