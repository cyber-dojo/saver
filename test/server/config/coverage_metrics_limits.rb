
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2050 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 12   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1338 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 155  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
