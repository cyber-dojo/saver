
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 1966 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 12   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1316 ],
    [ 'code.lines.missed'   , '<=', 12   ],
    [ 'code.branches.total' , '<=', 155  ],
    [ 'code.branches.missed', '<=', 4    ],
  ]
end
