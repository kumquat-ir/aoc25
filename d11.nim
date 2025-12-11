import std/[critbits, deques, sequtils, setutils, strutils]

type Device = object
  name: string
  links: set[int16]

let input = "d11.input".lines.toSeq.mapIt(it.split(' '))
var
  devices: seq[Device]
  dev_map: CritBitTree[int16]
  n = 0'i16
  you: int16
  svr: int16
  fft: int16
  dac: int16

for dev in input:
  let name = dev[0][0..^2]
  devices.add Device(name: name)
  dev_map[name] = n
  if name == "you":
    you = n
  elif name == "svr":
    svr = n
  elif name == "fft":
    fft = n
  elif name == "dac":
    dac = n
  inc n
dev_map["out"] = -1
for i in 0 ..< devices.len:
  let links = input[i][1..^1]
  devices[i].links = links.mapIt(dev_map[it]).toSet

proc incrAll(root: int16, by: int, only: set[int16], over: var seq[int]) =
  var
    queue: Deque[int16]
    seen: set[int16]

  queue.addLast(root)

  while queue.len > 0:
    let devi = queue.popFirst()
    if devi in seen:
      continue
    seen.incl devi
    for ndev in devices[devi].links:
      if ndev in only:
        queue.addLast(ndev)
        over[ndev] += by

proc pathsBetween(i1, i2: int16): int =
  var
    queue: Deque[int16]
    seen: set[int16]
    queued: set[int16]
    mult = newSeq[int](devices.len)
    finals: set[int16]

  queue.addLast(i1)
  mult[i1] = 1

  while queue.len > 0:
    let devi = queue.popFirst()
    if devi in seen:
      continue
    seen.incl devi
    for ndev in devices[devi].links:
      if ndev == i2:
        finals.incl devi
        continue
      elif ndev == -1:
        continue
      mult[ndev] += mult[devi]
      queue.addLast(ndev)
      queued.incl ndev
      if ndev in seen:
        # we've already seen this node! need to add the new multiplicity to all its descendants that have already been queued
        incrAll(ndev, mult[devi], queued, mult)
  for i in finals:
    result += mult[i]

proc part1(): int =
  pathsBetween(you, -1)

proc part2(): int =
  assert pathsBetween(dac, fft) == 0, "dac was positioned incorrectly (somehow)"
  pathsBetween(svr, fft) * pathsBetween(fft, dac) * pathsBetween(dac, -1)

echo "total paths: ", part1()
echo "paths through fft and dac: ", part2()
