## Sorting algorithms and binary search.

import std/random

proc insertionSort*[T](a: var seq[T]) =
  ## Sort `a` in place using insertion sort. O(n^2) worst case.
  for i in 1 ..< a.len:
    var j = i
    while j > 0 and a[j] < a[j-1]:
      swap(a[j], a[j-1])
      dec j

proc merge*[T](a: var seq[T], p, q, r: int) =
  ## Merge step used by both recursive and iterative mergesort.
  var b: seq[T] = @[]
  var i = p
  var j = q
  while true:
    if a[i] <= a[j]:
      b.add a[i]; inc i
    else:
      b.add a[j]; inc j
    if i == q:
      while j < r: b.add a[j]; inc j
      break
    if j == r:
      while i < q: b.add a[i]; inc i
      break
  for k in 0 ..< b.len:
    a[p + k] = b[k]

proc mergesort*[T](a: var seq[T], p = 0, r = -1) =
  ## Sort `a[p..<r]` in place using merge sort. O(n log n).
  let r = if r < 0: a.len else: r
  if p < r - 1:
    let q = (p + r) div 2
    mergesort(a, p, q)
    mergesort(a, q, r)
    merge(a, p, q, r)

proc mergesortNonrecursive*[T](a: var seq[T]) =
  ## Bottom-up (non-recursive) merge sort. O(n log n).
  let n = a.len
  var blocksize = 1
  while blocksize < n:
    var p = 0
    while p < n:
      let q = p + blocksize
      let r = min(q + blocksize, n)
      if r > q:
        merge(a, p, q, r)
      p += 2 * blocksize
    blocksize *= 2

proc partition[T](a: var seq[T], i, j: int): int =
  let x = a[i]
  var h = i
  for k in i+1 ..< j:
    if a[k] < x:
      inc h
      swap(a[h], a[k])
  swap(a[h], a[i])
  return h

proc quicksort*[T](a: var seq[T], p = 0, r = -1) =
  ## Randomized quicksort. O(n log n) expected.
  let r = if r < 0: a.len else: r
  if p < r - 1:
    let q0 = rand(p .. r - 1)
    swap(a[p], a[q0])
    let q = partition(a, p, r)
    quicksort(a, p, q)
    quicksort(a, q + 1, r)

proc countingsort*(a: var seq[int]) =
  ## Counting sort for non-negative integers. O(n + max(a)).
  if a.len == 0: return
  var lo = a[0]
  var hi = a[0]
  for v in a:
    if v < lo: lo = v
    if v > hi: hi = v
  if lo < 0:
    raise newException(ValueError, "countingsort requires non-negative ints")
  let k = hi + 1
  var c = newSeq[int](k)
  for v in a: inc c[v]
  var i = 0
  for j in 0 ..< k:
    while c[j] > 0:
      a[i] = j
      dec c[j]
      inc i

proc binarySearch*[T](a: openArray[T], element: T): int =
  ## Index of `element` in sorted `a`, or -1 if not present.
  var lo = 0
  var hi = a.len - 1
  while hi >= lo:
    let x = (lo + hi) div 2
    if a[x] < element: lo = x + 1
    elif a[x] > element: hi = x - 1
    else: return x
  return -1
