import std/[sequtils, strutils, strscans]

const present_size = 3

type
  Present = object
    grid: seq[seq[bool]]
    tiles: int
  Area = object
    width, height: int
    presents: seq[int]

var
  on_presents = true
  in_present = false
  cur_present: Present

  presents: seq[Present]
  areas: seq[Area]
  total = 0

for line in "d12.input".lines:
  if on_presents:
    if in_present:
      if line.isEmptyOrWhitespace:
        cur_present.tiles = cur_present.grid.mapIt(it.countIt(it)).foldl(a + b)
        presents.add cur_present
        in_present = false
      else:
        cur_present.grid.add line.mapIt(it == '#')
    else:
      if line.endsWith(':'):
        in_present = true
        cur_present = Present()
      else:
        on_presents = false
  if not on_presents:
    let (_, w, h) = line.scanTuple("$ix$i: ")
    areas.add Area(width: w, height: h, presents: line.split(' ')[1..^1].mapIt(it.parseInt))

for area in areas:
  let
    max_trivial_presents = (area.width div present_size) * (area.height div present_size)
    max_tiles = area.width * area.height
    num_presents = area.presents.foldl(a + b)
    num_tiles = zip(area.presents, presents).mapIt(it[0] * it[1].tiles).foldl(a + b)

  if num_presents <= max_trivial_presents:
    inc total
  elif num_tiles <= max_tiles:
    assert false, "nontrivial case! surely there will be at least one of these... right?"

echo "max presents: ", total
