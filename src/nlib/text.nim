## Sequence-alignment dynamic-programming algorithms.

proc lcs*(a, b: string): int =
  ## Length of longest common subsequence. O(|a| * |b|).
  if a.len == 0 or b.len == 0: return 0
  var previous = newSeq[int](b.len)
  var current = newSeq[int](b.len)
  for i, r in a:
    for j, c in b:
      var e: int
      if r == c:
        e = (if i * j > 0: previous[j-1] + 1 else: 1)
      else:
        let up = if i > 0: previous[j] else: 0
        let lf = if j > 0: current[j-1] else: 0
        e = max(up, lf)
      current[j] = e
    previous = current
  result = current[^1]

proc needlemanWunsch*(a, b: string, p = 0.97): seq[seq[float]] =
  ## Global sequence alignment scoring matrix.
  var z: seq[seq[float]] = @[]
  for i, r in a:
    var row: seq[float] = @[]
    for j, c in b:
      var e: float
      if r == c:
        e = if i * j > 0: z[i-1][j-1] + 1.0 else: 1.0
      else:
        let up = if i > 0: z[i-1][j] else: 0.0
        let lf = if j > 0: row[j-1] else: 0.0
        e = p * max(up, lf)
      row.add e
    z.add row
  result = z
