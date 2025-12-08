import std/[sugar, math, strutils, setutils, algorithm]

var
  points: seq[(int, int, int)]
  dists: seq[(float32, uint16, uint16)]
  circuits: seq[set[uint16]]

for line in "d8.input".lines:
  let p = line.split(',')
  points.add (parseInt(p[0]), parseInt(p[1]), parseInt(p[2]))

for i in 0 ..< points.len:
  let p1 = points[i]
  for j in i + 1 ..< points.len:
    let p2 = points[j]
    dists.add (sqrt(float32 (p1[0] - p2[0])^2 + (p1[1] - p2[1])^2 + (p1[2] - p2[2])^2), uint16 i, uint16 j)

dists.sort((a, b) => cmp(a[0], b[0]))

let fullset = (0'u16 ..< uint16 points.len).toSet
var last2: (uint16, uint16)
for (_, i1, i2) in dists:
  var
    added = -1
    c = 0
  while c < circuits.len:
    if i1 in circuits[c] or i2 in circuits[c]:
      if added != -1:
        circuits[added].incl circuits[c]
        circuits.delete c
      else:
        circuits[c].incl {i1, i2}
        added = c
        inc c
    else:
      inc c
  if added == -1:
    circuits.add {i1, i2}
  elif circuits.len == 1 and circuits[0] == fullset:
    last2 = (i1, i2)
    break

echo "product of last 2 x coords: ", points[last2[0]][0] * points[last2[1]][0]
