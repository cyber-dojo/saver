
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2855 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 4    ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1549 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 187  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
