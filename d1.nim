import std/[strutils]

var
  pos = 50
  count = 0

proc rot(dir: char, amti: int) =
  var amt: int
  if dir == 'L':
    amt = -amti
  elif dir == 'R':
    amt = amti

  let sp0 = pos == 0
  pos += amt
  if pos == 0:
    inc count
  elif pos > 0:
    count += pos div 100
    pos = pos mod 100
  elif pos < 0:
    if sp0:
      pos += 100
    while pos < 0:
      pos += 100
      inc count
    if pos == 0:
      inc count

for line in "d1.input".lines:
  let dir = line[0]
  let amt = parseInt(line[1..^1])
  rot(dir, amt)

echo "number of zeros: ", count
