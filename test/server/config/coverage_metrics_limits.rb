
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2778 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 14   ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1510 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 217  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
