
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 3178 ],
    [ 'test.lines.missed'   , '<=', 1    ],
    [ 'test.branches.total' , '<=', 6    ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1654 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 221  ],
    [ 'code.branches.missed', '<=', 1    ],
  ]
end
