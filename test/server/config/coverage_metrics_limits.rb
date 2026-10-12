
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 3234 ],
    [ 'test.lines.missed'   , '==',    0 ],
    [ 'test.branches.total' , '<=',    4 ],
    [ 'test.branches.missed', '==',    0 ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 1595 ],
    [ 'code.lines.missed'   , '==',    0 ],
    [ 'code.branches.total' , '<=',  209 ],
    [ 'code.branches.missed', '==',    0 ],
  ]
end
