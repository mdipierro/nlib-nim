import std/[unittest, random, algorithm]
import nlib/heap

suite "heap":
  randomize(7)

  test "heapify produces a valid max-heap":
    var a = @[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
    heapify(a)
    # parent >= each child
    for i in 0 ..< a.len:
      let l = 2*i + 1; let r = 2*i + 2
      if l < a.len: check a[i] >= a[l]
      if r < a.len: check a[i] >= a[r]

  test "heapsort":
    var a = newSeq[int](100)
    for i in 0 ..< 100: a[i] = rand(1000)
    var expected = a; expected.sort()
    heapsort(a)
    check a == expected

  test "heapPush / heapPop yields descending order":
    var heap: seq[int] = @[]
    for v in [6, 2, 7, 9, 3]:
      heapPush(heap, v)
    var popped: seq[int] = @[]
    while heap.len > 0:
      popped.add heapPop(heap)
    check popped == @[9, 7, 6, 3, 2]

  test "heapPop on empty raises":
    var heap: seq[int] = @[]
    expect IndexDefect:
      discard heapPop(heap)
