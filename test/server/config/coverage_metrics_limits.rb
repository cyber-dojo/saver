
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 3236 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 6    ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1642 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 221  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
