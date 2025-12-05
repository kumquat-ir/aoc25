import std/[sugar, algorithm, strutils]

var
  fresh: seq[(int, int)]
  total = 0

proc merge(r: (int, int), fr: var (int, int)): bool =
  if r[1] >= fr[0]:
    if r[1] >= fr[1]:
      fr[1] = r[1]
    fr[0] = r[0]
    return true
  false

for line in "d5.input".lines:
  if line.len == 0:
    break
  let raw = line.split("-")
  fresh.add((parseInt(raw[0]), parseInt(raw[1])))

fresh.sort((a, b) => cmp(a[0], b[0]))

var i = 0
while i < fresh.len - 1:
  if merge(fresh[i], fresh[i+1]):
    fresh.delete(i)
  else:
    inc i

for r in fresh:
  total += r[1] - r[0] + 1

echo total
