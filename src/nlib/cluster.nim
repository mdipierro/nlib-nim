## Hierarchical (agglomerative) clustering.

import std/[algorithm, tables]

type
  ClusterEntry = object
    case isList: bool
    of true: members: seq[int]
    of false: parentId: int

  Cluster*[T] = ref object
    points*: seq[T]
    metric*: proc(a, b: T): float
    k*: int
    w*: seq[float]
    q*: Table[int, ClusterEntry]
    d*: seq[(float, int, int)]
    dd*: seq[(float, int)]
    r*: float
    v*: seq[seq[int]]

proc newCluster*[T](points: seq[T],
                    metric: proc(a, b: T): float,
                    weights: seq[float] = @[]): Cluster[T] =
  result = Cluster[T](points: points, metric: metric, k: points.len)
  result.w = if weights.len > 0: weights
             else: (block:
               var ws = newSeq[float](points.len)
               for i in 0 ..< points.len: ws[i] = 1.0
               ws)
  for i in 0 ..< points.len:
    result.q[i] = ClusterEntry(isList: true, members: @[i])
  for i in 0 ..< points.len:
    for j in i + 1 ..< points.len:
      let m = metric(points[i], points[j])
      if not m.isNaN:
        result.d.add (m, i, j)
  result.d.sort()

proc parent*[T](c: Cluster[T], i: int): (int, seq[int]) =
  var i = i
  while c.q[i].isList == false:
    i = c.q[i].parentId
  (i, c.q[i].members)

proc step*[T](c: Cluster[T]): (float, seq[seq[int]]) =
  if c.k > 1:
    let head = c.d[0]
    c.r = head[0]
    var i = head[1]
    var j = head[2]
    c.d.delete(0)
    let (pi, x) = c.parent(i)
    let (pj, y) = c.parent(j)
    var merged = x & y
    c.q[pi] = ClusterEntry(isList: true, members: merged)
    c.q[pj] = ClusterEntry(isList: false, parentId: pi)
    dec c.k
    var newD: seq[(float, int, int)] = @[]
    var oldD = initTable[int, (float, float)]()
    for (r, h, k) in c.d:
      if h in [pi, pj]:
        let (a, b) = oldD.getOrDefault(k, (0.0, 0.0))
        oldD[k] = (a + c.w[k] * r, b + c.w[k])
      elif k in [pi, pj]:
        let (a, b) = oldD.getOrDefault(h, (0.0, 0.0))
        oldD[h] = (a + c.w[h] * r, b + c.w[h])
      else:
        newD.add (r, h, k)
    for k, ab in tables.pairs(oldD):
      newD.add (ab[0] / ab[1], pi, k)
    newD.sort()
    c.d = newD
    c.w[pi] = c.w[pi] + c.w[pj]
    var v: seq[seq[int]] = @[]
    for _, e in tables.pairs(c.q):
      if e.isList: v.add e.members
    c.v = v
    c.dd.add (c.r, c.v.len)
  (c.r, c.v)

proc find*[T](c: Cluster[T], k: int): (float, seq[seq[int]]) =
  while c.k > k:
    discard c.step()
  (c.r, c.v)
