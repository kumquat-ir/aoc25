import std/[rationals, sequtils, strutils, setutils, algorithm, sugar]
export rationals

type
  LinEq* = object
    cols: seq[Rational[int]]
    bound: Rational[int]
    leading: int
  LinEqs* = object
    rows: seq[LinEq]
    ncols: int
  LinSol* = object
    consistent*: bool
    basic*: seq[Rational[int]]
    free*: seq[seq[Rational[int]]]

func linEq(cols: seq[Rational[int]], bound: Rational[int]): LinEq =
  result.bound = bound
  result.cols = cols
  result.leading = cols.findIt(it != 0 // 1)
  if result.leading == -1:
    result.leading = cols.len

func linEq*(cols: openArray[int], bound: int): LinEq =
  linEq(cols.mapIt(it.toRational), bound.toRational)

func `+`*(a, b: LinEq): LinEq =
  linEq(zip(a.cols, b.cols).mapIt(it[0] + it[1]), a.bound + b.bound)

func `*`*(self: LinEq, by: Rational[int]): LinEq =
  linEq(self.cols.mapIt(it * by), self.bound * by)

func `*`*(self: LinEq, by: int): LinEq =
  self * by.toRational

func `$`*(self: LinEq): string =
  $self.cols & "\t| " & $self.bound & "\t" & $self.leading

func linEqs*(cols: seq[seq[int]], bounds: seq[int]): LinEqs =
  for i in 0 ..< cols[0].len:
    result.rows.add linEq(cols.mapIt(it[i]), bounds[i])
  result.ncols = cols.len

func swap*(self: var LinEqs, i, j: int) =
  let tmp = self.rows[i]
  self.rows[i] = self.rows[j]
  self.rows[j] = tmp

func mult*(self: var LinEqs, i: int, by: Rational[int] or int) =
  self.rows[i] = self.rows[i] * by

func add*(self: var LinEqs, i: int, by: Rational[int] or int, j: int) =
  self.rows[j] = self.rows[j] + (self.rows[i] * by)

func refp*(self: LinEqs): bool =
  var found_zero = false
  for i in 0 ..< self.rows.len:
    if self.rows[i].leading == self.ncols:
      found_zero = true
    elif found_zero:
      return false
    elif i > 0 and self.rows[i].leading <= self.rows[i-1].leading:
      return false
  true

func rrefp*(self: LinEqs): bool =
  if not self.refp:
    return false
  for i in 0 ..< self.rows.len:
    let leading = self.rows[i].leading
    if leading == self.ncols:
      continue
    if self.rows[i].cols[leading] != 1 // 1:
      return false
    for j in 0 ..< i:
      if self.rows[j].cols[leading] != 0 // 1:
        return false
  true

func `$`*(self: LinEqs): string =
  for r in self.rows:
    result.addSep("\n")
    result.add $r

func sort_leading*(self: var LinEqs) =
  self.rows.sort((a, b) => cmp(a.leading, b.leading))

proc solve*(self: var LinEqs): LinSol =
  self.sort_leading()
  for i in 0 ..< self.ncols:
    let frowi = self.rows.findIt(it.leading == i)
    if frowi == -1:
      continue
    let frow = self.rows[frowi]
    # echo frow
    for r in frowi + 1 ..< self.rows.len:
      if self.rows[r].leading == i:
        # echo self.rows[r], " / ", -self.rows[r].cols[i] / frow.cols[i]
        self.add(frowi, -self.rows[r].cols[i] / frow.cols[i], r)
  # echo "ref: ", self.refp()
  # echo "refed:\n", self

  for i in 0 ..< self.rows.len:
    if self.rows[i].leading != self.ncols:
      self.mult(i, 1 / self.rows[i].cols[self.rows[i].leading])

  # echo "reduced:\n", self

  for i in countdown(self.ncols - 1, 0):
    let frowi = self.rows.findIt(it.leading == i)
    if frowi == -1:
      continue
    let frow = self.rows[frowi]
    # echo frow
    for r in countdown(frowi - 1, 0):
      let rn = self.rows[r].cols[i]
      if rn != 0 // 1:
        # echo self.rows[r], " / ", -self.rows[r].cols[i] / frow.cols[i]
        self.add(frowi, -self.rows[r].cols[i] / frow.cols[i], r)

  # echo "rref: ", self.rrefp()
  echo "rrefed:\n", self

  result.consistent = true
  for row in self.rows:
    if row.leading == self.ncols and row.bound != 0 // 1:
      result.consistent = false
      return

  let leadings: set[uint8] = self.rows.mapIt(uint8 it.leading).toSet
  result.basic = newSeqWith(self.ncols, 0 // 1)
  # result.free = newSeq[seq[Rational[int]]](self.ncols - leadings.len)
  for i in 0 ..< self.ncols:
    if (uint8 i) in leadings:
      let r = self.rows.findIt(it.leading == i)
      result.basic[i] = self.rows[r].bound
    else:
      var nfree = newSeqWith(self.ncols, 0 // 1)
      for r in 0 ..< self.rows.len:
        let l = self.rows[r].leading
        if l != self.ncols:
          nfree[l] = -self.rows[r].cols[i]
      nfree[i] = 1 // 1
      result.free.add nfree

proc solve*(cols: seq[seq[int]], bounds: seq[int]): LinSol =
  var mat = linEqs(cols, bounds)
  mat.solve()

type Dir* = enum dRight, dUp, dLeft, dDown

func turn*(self: Dir, to: Dir): Dir =
  case self
  of dRight:
    if to == dRight: dDown else: dUp
  of dUp:
    if to == dRight: dRight else: dLeft
  of dLeft:
    if to == dRight: dUp else: dDown
  of dDown:
    if to == dRight: dLeft else: dRight

func flip*(self: Dir): Dir =
  case self
  of dRight: dLeft
  of dUp: dDown
  of dLeft: dRight
  of dDown: dUp


when isMainModule:
  var a = linEqs(@[@[1, 4, 5], @[2, 0, 4], @[1, 0, 2]], @[4, 12, 4])
  echo a, "\n"
  a.mult(1, 1 // 2)
  echo a, "\n"
  a.swap(1, 2)
  echo a, "\n"
  a.add(0, -5, 1)
  a.add(0, -2, 2)
  echo a, " ", a.refp, "\n"
  a.add(1, -2 // 3, 2)
  echo a, " ", a.refp, "\n"

  var b = linEqs(@[@[1, 0, 0], @[0, 0, 1], @[1, 0, 0]], @[0, 0, 0])
  echo b, "\t", b.refp, "\t", b.rrefp, "\n"
  b.sort_leading()
  echo b, "\t", b.refp, "\t", b.rrefp, "\n"

  a = linEqs(@[@[1, 4, 5], @[2, 0, 4], @[1, 0, 2]], @[4, 12, 17])
  echo a.solve()
  echo a
  echo b.solve
