import std/[sequtils]

var
  layout: seq[string]
  totals: seq[seq[int8]]
  total = 0
  work = true

layout = lines("d4.input").toSeq

totals = newSeqWith(layout.len + 2, newSeq[int8](layout[0].len + 2))

for i in 0..<layout.len:
  for j in 0..<layout[i].len:
    if layout[i][j] == '@':
      # i feel like this could be improved but whatever
      inc totals[i][j]
      inc totals[i][j+1]
      inc totals[i][j+2]
      inc totals[i+1][j]
      inc totals[i+1][j+2]
      inc totals[i+2][j]
      inc totals[i+2][j+1]
      inc totals[i+2][j+2]

while work:
  work = false
  for i in 0..<layout.len:
    for j in 0..<layout[i].len:
      if layout[i][j] == '@' and totals[i+1][j+1] < 4:
        inc total
        dec totals[i][j]
        dec totals[i][j+1]
        dec totals[i][j+2]
        dec totals[i+1][j]
        dec totals[i+1][j+2]
        dec totals[i+2][j]
        dec totals[i+2][j+1]
        dec totals[i+2][j+2]
        layout[i][j] = '.'
        work = true

echo total
