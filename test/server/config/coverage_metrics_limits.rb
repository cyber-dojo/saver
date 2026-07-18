
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 3346 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 6    ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1649 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 217  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
