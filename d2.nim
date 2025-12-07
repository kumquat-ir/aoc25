import std/[strutils, math]

var total: int

proc isRep(i: int): bool =
  let l = (i+1).toFloat.log10.ceil.toInt
  for nr in 2..l:
    if l mod nr == 0:
      var
        prev = i mod 10^(l div nr)
        found = true
      for n in 1..<nr:
        if (i div 10^((l div nr)*n)) mod 10^(l div nr) != prev:
          found = false
          break
      if found:
        return true
  false

for rin in readFile("d2.input").split(','):
  let rsplit = rin.split('-')
  for i in parseInt(rsplit[0]) .. parseInt(rsplit[1]):
    if i.isRep():
      total += i

echo "sum of invalid ids: ", total
