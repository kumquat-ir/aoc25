import std/[strutils, sequtils, setutils, math, bitops]
import ./util
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

proc part2(): int =
  for machine in machines:
    var bseqs = newSeqWith(machine.buttons.len, newSeq[int](machine.joltage.len))
    for i in 0 ..< bseqs.len:
      for j in 0 ..< bseqs[i].len:
        if j in machine.buttons[i]:
          bseqs[i][j] = 1

    # gaussian elimination equation solver
    # might leave us with some free variables to deal with, but thats still reducing the problem size
    let sol = solve(bseqs, machine.joltage)

    var
      basic = sol.basic
      free = sol.free
      nfree: seq[seq[Rational[int]]]
    # there can be fractions here - need to get rid of those if there are any
    if basic.anyIt(it.den > 1):
      # fractions in the base case - eliminate by adding free variables
      let
        dens = basic.mapIt(it.den)
        elimi = sol.free.findIt(it.mapIt(it.den) == dens)
        # assumes that if no one free var is suitable for eliminating the denominators, we can use all of them
        # and that all denominators are the same
        # and that simply adding the free var is enough to eliminate them
        # works on my input(tm)
        elims = if elimi == -1: (0 ..< sol.free.len).toSeq else: @[elimi]
      for i in elims:
        basic = zip(basic, sol.free[i]).mapIt(it[0] + it[1])

    for i in 0 ..< free.len:
      if free[i].anyIt(it.den > 1):
        let
          other = free[(i+1)..^1].findIt(it.mapIt(it.den) == free[i].mapIt(it.den)) + i + 1
          den = free[i].mapIt(it.den).max
        if other > i and den == 2:
          # there may be a solution that requires they still be fractional - add a couple extra variables to check
          nfree.add zip(free[i], free[other]).mapIt(it[0] + it[1])
          nfree.add zip(free[i], free[other]).mapIt(it[0] - it[1])
        # fractions in a free variable - just multiply it
        free[i].applyIt(it * den)

    # we have now eliminated all the denominators - convert everything to ints
    var
      base = basic.mapIt(it.num)
      modifiers = free.mapIt(it.mapIt(it.num))
      nmods = nfree.mapIt(it.mapIt(it.num))

    var
      best = int.high
      bbase = base
    # brute force time!
    # in my input, there are at most 3 free variables, so this doesnt take too long
    for at in (if modifiers.len == 0: 0 else: 256^(modifiers.len - 1)) ..< 256^(modifiers.len):
      var
        attempt: seq[int]
        a = uint at
        abase = base

      while a > 0:
        attempt.add int(a and 0xFF) - 64 # offset to make it work on my input, ymmv
        a = a shr 8

      for i in 0 ..< attempt.len:
        abase = zip(abase, modifiers[i]).mapIt(it[0] + it[1] * attempt[i])

      let sum = abase.foldl(a + b)
      if sum < best and abase.allIt(it >= 0):
        best = sum
        bbase = abase
    base = bbase

    # smaller brute force for any extra variables
    for at in (if nmods.len == 0: 0 else: 16^(nmods.len - 1)) ..< 16^(nmods.len):
      var
        attempt: seq[int]
        a = uint at
        abase = base

      while a > 0:
        attempt.add int(a and 0xF) - 8
        a = a shr 4

      for i in 0 ..< attempt.len:
        abase = zip(abase, nmods[i]).mapIt(it[0] + it[1] * attempt[i])

      let sum = abase.foldl(a + b)
      if sum < best and abase.allIt(it >= 0):
        best = sum
        bbase = abase

    result += best

echo "total presses to configure lights: ", part1()
echo "total presses to configure joltage: ", part2()
