
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 3016 ],
    [ 'test.lines.missed'   , '<=', 0    ],
    [ 'test.branches.total' , '<=', 8    ],
    [ 'test.branches.missed', '<=', 0    ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1605 ],
    [ 'code.lines.missed'   , '<=', 0    ],
    [ 'code.branches.total' , '<=', 225  ],
    [ 'code.branches.missed', '<=', 0    ],
  ]
end
