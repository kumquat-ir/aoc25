import std/[strutils, sequtils, setutils, math, bitops, strscans]
import z3
import z3/z3_api

type
  LightRange = range[0..9]
  Machine = object
    light_config: set[LightRange]
    buttons: seq[set[LightRange]]
    joltage: seq[int]

var
  machines: seq[Machine]

for line in "d10.input".lines:
  let
    parts = line.split(' ')
    light_config = parts[0][1..^2].pairs.toSeq.filterIt(it[1] == '#').mapIt(LightRange it[0]).toSet
    buttons = parts[1..^2].mapIt(it[1..^2].split(',').mapIt(it.parseInt().LightRange).toSet)
    joltage = parts[^1][1..^2].split(',').mapIt(it.parseInt())
  machines.add Machine(light_config: light_config, buttons: buttons, joltage: joltage)

proc part1(): int =
  for machine in machines:
    let maxi = 2^(machine.buttons.len) - 1
    var best = machine.buttons.len + 1
    for i in 0..maxi:
      let count = countSetBits(i)
      if count >= best:
        continue
      var test: set[LightRange]
      for b in cast[set[0 .. 15]](i): # should be wide enough
        test.toggle(machine.buttons[b])
      if test == machine.light_config:
        best = count
        if best == 1:
          break
    result += best

{.push warning[CStringConv]:off .}
proc part2(): int =
  for machine in machines:
    var bseqs = newSeqWith(machine.buttons.len, newSeq[int](machine.joltage.len))
    for i in 0 ..< bseqs.len:
      for j in 0 ..< bseqs[i].len:
        if j in machine.buttons[i]:
          bseqs[i][j] = 1
    var r: string
    z3: # jank but it works
      let s = Optimizer()
      var
        ns: seq[Z3_ast_int]
        js: seq[Z3_ast_int]
      for i in 0 ..< machine.joltage.len:
        js.add Int("j" & $i)
        s.assert js[i] == machine.joltage[i]
      var sum: Z3_ast_int
      for i in 0 ..< bseqs.len:
        ns.add Int("n" & $i)
        s.assert ns[i] >= 0
        if i == 0:
          sum = ns[i]
        else:
          sum = sum + ns[i]
      for i in 0 ..< bseqs[0].len:
        var row: seq[Z3_ast_int]
        for j in 0 ..< bseqs.len:
          if bseqs[j][i] == 1:
            row.add ns[j]
        var rsum: Z3_ast_int = row[0]
        for j in 1 ..< row.len:
          rsum = rsum + row[j]
        s.assert rsum == js[i]
      discard Z3_optimize_minimize(ctx, s, sum.Z3_ast)
      assert s.check() == Z3_L_TRUE
      r = $s.get_model()

    for line in r.splitLines:
      var b, n: int
      if line.scanf("n$i -> $i", b, n):
        result += n

echo "total presses to configure lights: ", part1()
echo "total presses to conifgure joltage: ", part2()
