import std/[sugar, strutils, sequtils]

let rows = "d6.input".lines.toSeq
var
  problems: seq[(char, seq[int])]
  total = 0
  si = 0

proc addProblem(si: int, i: int) =
  let cur = rows[0..^2].map((s) => s[si .. i])
  var args: seq[int]
  for j in 0 ..< cur[0].len:
    args.add parseInt(cur.map((s) => s[j]).foldl(a & b, "").strip)
  problems.add (rows[^1][si], args)

for i in 1 ..< rows[0].len:
  if rows[^1][i] != ' ':
    addProblem(si, i - 2)
    si = i
addProblem(si, rows[0].len - 1)

for problem in problems:
  case problem[0]
    of '+': total += problem[1].foldl(a + b)
    of '*': total += problem[1].foldl(a * b)
    else: raise newException(ValueError, "invalid op $1" % $problem[0])

echo total
