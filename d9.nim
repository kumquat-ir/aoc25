import std/[sugar, strutils, sequtils]

type Dir = enum dRight, dUp, dLeft, dDown

func turn(self: Dir, to: Dir): Dir =
  case self
  of dRight:
    if to == dRight: dDown else: dUp
  of dUp:
    if to == dRight: dRight else: dLeft
  of dLeft:
    if to == dRight: dUp else: dDown
  of dDown:
    if to == dRight: dLeft else: dRight

func flip(self: Dir): Dir =
  case self
  of dRight: dLeft
  of dUp: dDown
  of dLeft: dRight
  of dDown: dUp

type Edge = object
  i1, i2: int
  dir: Dir
  along: (int, int)
  cross: int

proc edge(cross, along1, along2: int, dir: Dir, i1, i2: int): Edge =
  Edge(cross: cross, along: (along1, along2), dir: dir, i1: i1, i2: i2)

var
  tiles: seq[(int, int)]
  h_edges: seq[Edge]
  v_edges: seq[Edge]
  prev_dir: Dir
  turns = (0, 0)
  first_turn_done = false
  chirality: Dir
  max_area = 0

proc intersects_any(t1, t2: (int, int)): bool =
  let
    min_x = min(t1[0], t2[0]) + 1
    max_x = max(t1[0], t2[0]) - 1
    min_y = min(t1[1], t2[1]) + 1
    max_y = max(t1[1], t2[1]) - 1
  h_edges.any((e) => e.cross >= min_y and e.cross <= max_y and ((e.along[0] <= min_x and e.along[1] >= min_x) or (e.along[0] <= max_x and e.along[1] >= max_x))) or
  v_edges.any((e) => e.cross >= min_x and e.cross <= max_x and ((e.along[0] <= min_y and e.along[1] >= min_y) or (e.along[0] <= max_y and e.along[1] >= max_y)))

proc inside(i1, i2: int): bool =
  # i'm not sure whether this check is entirely correct
  # the real input seems to be structured in a way that makes it mostly irrelevant
  let
    t1 = tiles[i1]
    t2 = tiles[i2]
  if t1[0] == t2[0] or t1[1] == t2[1]:
    return true # this check is unnecessary for thin rects
  let # this = a horrible mess
    h = h_edges.filter((e) => e.i1 == i1 or e.i2 == i1)[0]
    hdir = if t1[0] > t2[0]: dLeft else: dRight
    v = v_edges.filter((e) => e.i1 == i1 or e.i2 == i1)[0]
    vdir = if t1[1] > t2[1]: dDown else: dUp
    h_on = if h.i1 == i1: hdir == h.dir else: hdir.flip == h.dir
    v_on = if v.i1 == i1: vdir == v.dir else: vdir.flip == v.dir
    eff_h_dir = if h_on: h.dir else: h.dir.flip
    eff_v_dir = if v_on: v.dir else: v.dir.flip
    eff_chirality = if not h_on and not v_on: chirality.flip else: chirality
  eff_h_dir.turn(eff_chirality) == vdir and eff_v_dir.turn(eff_chirality) == hdir

for line in "d9.input".lines:
  let t = line.split(',')
  tiles.add (parseInt(t[0]), parseInt(t[1]))

for i in 1 .. tiles.len:
  let
    t1 = tiles[i - 1]
    t2 = tiles[i mod tiles.len] # to get the first/last pair
  var dir: Dir
  if t1[0] == t2[0]:
    dir = if t1[1] > t2[1]: dDown else: dUp
    v_edges.add edge(t1[0], min(t1[1], t2[1]), max(t1[1], t2[1]), dir, i - 1, i mod tiles.len)
  else:
    dir = if t1[0] > t2[0]: dLeft else: dRight
    h_edges.add edge(t1[1], min(t1[0], t2[0]), max(t1[0], t2[0]), dir, i - 1, i mod tiles.len)

  if not first_turn_done:
    first_turn_done = true
  elif prev_dir.turn(dLeft) == dir:
    inc turns[0]
  else:
    inc turns[1]
  prev_dir = dir

if turns[0] > turns[1]:
  chirality = dLeft
else:
  chirality = dRight

for i in 0 ..< tiles.len:
  let t1 = tiles[i]
  for j in i + 1 ..< tiles.len:
    let
      t2 = tiles[j]
      area = (abs(t1[0] - t2[0]) + 1) * (abs(t1[1] - t2[1]) + 1)
    if area > max_area and not intersects_any(t1, t2) and inside(i, j):
      max_area = area

echo "maximum area: ", max_area
