
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
