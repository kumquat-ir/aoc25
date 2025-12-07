import std/[sequtils, strutils]

let lines = "d7.input".lines.toSeq
var
  beams: set[uint8]
  mults = newSeq[int](lines[0].len)
  splits = 0

for i in 0 ..< lines[0].len:
  if lines[0][i] == 'S':
    beams.incl uint8 i
    inc mults[i]

for line in lines[1..^1]:
  var
    nbeams: set[uint8]
    nmults = newSeq[int](line.len)
  for beam in beams:
    case line[beam]
      of '.':
        nbeams.incl beam
        nmults[beam] += mults[beam]
      of '^':
        nbeams.incl {beam - 1, beam + 1}
        nmults[beam - 1] += mults[beam]
        nmults[beam + 1] += mults[beam]
        inc splits
      else: raise newException(ValueError, "unknown symbol $1" % $line[beam])
  beams = nbeams
  mults = nmults

echo "number of splits: ", splits
echo "number of timelines: ", mults.foldl(a + b)
