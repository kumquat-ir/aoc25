import std/[strutils]

var total = 0

const numbats = 12

for line in "d3.input".lines:
  var
    linetotal = 0
    start = 0
  for b in 1..numbats:
    var largest = (-1, -1)
    for i in start..<(line.len - numbats + b):
      let n = parseInt($line[i])
      if n > largest[1]:
        largest = (i, n)
    start = largest[0] + 1
    linetotal *= 10
    linetotal += largest[1]
  total += linetotal

echo total
