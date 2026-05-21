
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 2745 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 4    ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1506 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 217  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
